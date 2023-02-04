//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Vapor
import Fluent


class ChatBotService {
    private let client: any ChatbotClientProtocol<ChatSession, ChatUser>
    private let db: Database
    
    
    init(client: any ChatbotClientProtocol<ChatSession, ChatUser>, db: Database) {
        self.client = client
        self.db = db
    }
    
    func clearHistory(userId: String) async throws {
        guard let user = try await ChatUser.query(on: db).filter(\.$userId == userId).first() else {
            throw Abort(.notFound)
        }
        try await user.$chat.query(on: db).delete()
    }
    
    /**
     Generates response from user with message and save the response to the database
     */
    func replyTo(user: ChatUser, _ userMessage: String) async throws -> String {
        var previousUser = try await ChatUser.query(on: db).filter(\.$userId == user.userId).first()
        let message = try await previousUser?.$chat.get(on: db)
        
        if previousUser == nil {
            try await user.save(on: db)
            previousUser = user
        }
        
        try await client.load(message: message, for: user)
        let response = try await client.sendMessage(userMessage)
        let session = try await client.save()
        if let message = message {
            message.history = session.history
            try await message.save(on: db)
        } else {
            try await previousUser!.$chat.create(session, on: db)
        }
        client.onDestory()
        return response
    }
}
