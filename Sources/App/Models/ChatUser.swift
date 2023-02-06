//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Fluent
import Vapor
import TelegramBotSDK

final class ChatUser: Content, Model, UserProtocol {
    static let schema = "chat-user"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "userId")
    var userId: String
    
    @Field(key: "userName")
    var userName: String
    
    @OptionalChild(for: \.$user)
    var chat: ChatSession?
    
    init() {
        
    }
    
    
    init(userId: String, userName: String) {
        self.userId = userId
        self.userName = userName
    }
    
    static func from(user: TelegramBotSDK.User) -> ChatUser {
        var userName = ""
        if let name = user.username {
            userName = name
        } else {
            userName += user.firstName
            if let lastname = user.lastName {
                userName += " " + lastname
            }
        }
        
        return ChatUser(userId: String(user.id), userName: userName)
    }
}
