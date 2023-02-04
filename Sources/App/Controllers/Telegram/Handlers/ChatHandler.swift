//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//
import Foundation
import TelegramBotSDK

class ChatHandler: Handler, TelegramProtocol {
    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        if context.slash {
            context.respondAsync("Not supported command")
            return true
        }
        
        if let message = context.message, let text = message.text, let user = message.from {
            Task {
                bot.sendChatActionSync(chatId: .chat(context.chatId!), action: .typing)
                let result = try await service.replyTo(user: .init(userId: String(user.id), userName: user.username ?? "Anno"), text)
                context.respondSync(result)
            }
            
            return true
        }
        context.respondSync("You must enter some text input!")
        return false
    }
}
