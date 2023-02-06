//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/6/23.
//

import Foundation
import TelegramBotSDK

class ChatTypeHandler: Handler, TelegramProtocol {
    let type: ChatType
    
    init(service: ChatBotService, bot: TelegramBot, type: ChatType) {
        self.type = type
        super.init(service: service, bot: bot)
    }
    
    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        guard let user = context.message?.from else { return false }
        Task {
            try? await self.service.updateChatSessionType(user: .from(user: user), type: type)
            context.respondSync("Switched to \(type) mode")
        }
        return true
    }
}
