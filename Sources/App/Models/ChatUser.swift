//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Fluent
import Vapor

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
}
