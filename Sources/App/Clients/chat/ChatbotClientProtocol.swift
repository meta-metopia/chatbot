//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation

protocol MessageProtocol {
    
}

protocol UserProtocol {
    
}

/**
 Defines the interface for a chatbot client. Adherence to this protocol allows for compatibility with other systems.
 */
protocol ChatbotClientProtocol<Message, User> {
    associatedtype Message: MessageProtocol
    associatedtype User: UserProtocol
    associatedtype RawResponse: MessageProtocol
    
    func sendRaw(_ message: String) async throws -> [RawResponse]
    
    /**
     Sends a message to the chatbot and retrieves the response.
     */
    func sendMessage(_ message: String) async throws -> String
    
    /**
     Generates a message for saving to the database.
     @return The generated message.
     */
    func save() async throws -> Message
    
    /**
     Loads a message from the database into the client.
     @param message The message to be loaded.
     */
    func load(message: Message?, for: User) async throws
    
    func onDestory() -> Void
}
