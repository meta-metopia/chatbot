//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import TelegramBotSDK
import Vapor

protocol TelegramProtocol {
    func handle(context: Context) throws -> Bool
}

class Handler {
    let service: ChatBotService
    let bot: TelegramBot
    
    init(service: ChatBotService, bot: TelegramBot) {
        self.service = service
        self.bot = bot
    }
}
