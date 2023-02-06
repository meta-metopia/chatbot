//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Vapor
import Fluent
import AzureTextToSpeech

struct ChatBotServiceReplyResponse {
    var text: String
    var audioURL: URL?
    var localAudioURL: URL?
}


class ChatBotService {
    private let client: any ChatbotClientProtocol<ChatSession, ChatUser>
    private let speech: any TextToSpeechProtocol
//    private let s3Client: any S3FileProtocol
    private let db: Database
    
    
    init(client: any ChatbotClientProtocol<ChatSession, ChatUser>, db: Database, speech: any TextToSpeechProtocol) {
        self.client = client
        self.db = db
        self.speech = speech
    }
    
    func setup() async throws {
        try await speech.setup()
    }
    
    func updateChatSessionType(user: ChatUser, type: ChatType) async throws {
        if let user = try await ChatUser.query(on: db).filter(\.$userId == user.userId).first(){
            // if user exists
            let session = try await user.$chat.get(on: db)
            guard let session = session else {
                try await user.$chat.create(.init(history: nil, chatType: type), on: db)
                return
            }
            session.chatType = type
            try await session.save(on: db)
        }
        else {
            try await user.save(on: db)
            try await user.$chat.create(.init(history: nil, chatType: type), on: db)
        }
    }
    
    func generateAudio(_ text: String, session: ChatSession) async throws -> URL {
        let date = Date()
        let fileName = "\(session.id?.uuidString ?? "")_\(date.timeIntervalSince1970).ogg"
        return try await self.speech.toAudio(text, fileName: fileName)
    }
    
    func clearHistory(userId: String) async throws {
        guard let user = try await ChatUser.query(on: db).filter(\.$userId == userId).first() else {
            throw Abort(.notFound)
        }
        let chat = try await user.$chat.get(on: db)
        
        if let chat = chat {
            chat.history = nil
            try await chat.save(on: db)
        }
    }
    
    /**
     Generates response from user with message and save the response to the database
     */
    func replyTo(user: ChatUser, _ userMessage: String) async throws -> ChatBotServiceReplyResponse {
        var previousUser = try await ChatUser.query(on: db).filter(\.$userId == user.userId).first()
        var message = try await previousUser?.$chat.get(on: db)
        let audioURL: URL? = nil
        var localAudioURL: URL? = nil
        
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
            message = session
        }
        client.onDestory()
        if message?.chatType == .audio {
            let localURL = try await self.generateAudio(response, session: message!)
//            audioURL = try await s3Client.upload(from: localURL)
            localAudioURL = localURL
        }
        return ChatBotServiceReplyResponse(text: response, audioURL: audioURL, localAudioURL: localAudioURL)
    }
}
