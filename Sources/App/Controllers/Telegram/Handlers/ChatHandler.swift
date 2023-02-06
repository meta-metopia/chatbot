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
        
        if let message = context.message, let text = message.text, let user = message.from, let chatId = context.chatId {
            Task {
                bot.sendChatActionSync(chatId: .chat(context.chatId!), action: .typing)
                let result = try await service.replyTo(user: .from(user: user), text)
                if let audioURL = result.localAudioURL {
                    let content = try Data(contentsOf: audioURL)
                    bot.sendDocumentSync(chatId: .chat(chatId), document: .inputFile(.init(filename: audioURL.lastPathComponent, data: content)))
                    
                } else {
                    bot.sendMessageSync(chatId: .chat(chatId), text: result.text)
                }
            }
            
            return true
        }
        context.respondSync("You must enter some text input!")
        return false
    }
}
