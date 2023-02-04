//
//  File.swift
//
//
//  Created by Qiwei Li on 1/30/23.
//

import Foundation
import TelegramBotSDK

class HelpHandler: Handler, TelegramProtocol {
    func handle(context: TelegramBotSDK.Context) throws -> Bool {
        context.respondAsync("You can type any text to start chatting.\nType: /clear to reset.")
        return true
    }

}
