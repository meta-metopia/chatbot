//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import TelegramBotSDK

class ClearHandler: Handler, TelegramProtocol {    
    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        guard let user = context.message?.from else { return false }
        Task {
            try? await self.service.clearHistory(userId: String(user.id))
            context.respondSync("Message cleared!")
        }
        return true
    }
}
