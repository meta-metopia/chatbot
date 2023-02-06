//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Vapor
import TelegramBotSDK

enum TelegramErrors: LocalizedError {
    case missingKey(String)

}

class TelegramController: RouteCollection {
    var apiKey: String!
    var bot: TelegramBot!
    let service: ChatBotService
    var router: TelegramBotSDK.Router
    
    init(service: ChatBotService) throws {
        guard let apiKey = Environment.get("TELEGRAM_KEY") else {
            throw TelegramErrors.missingKey("TELEGRAM_KEY")
        }
        
        self.apiKey = apiKey
        self.bot = TelegramBot(token: apiKey)
        self.service = service
        self.router = Router(bot: bot)
        setupBotHandlers(router: &router)
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("webhook", .init(stringLiteral: apiKey), use: reply)
    }
    
    func setupBotHandlers(router: inout TelegramBotSDK.Router) {
        router[TelegramCommand.help.rawValue] = HelpHandler(service: service, bot: bot).handle
        router[TelegramCommand.clear.rawValue] = ClearHandler(service: service, bot: bot).handle
        router[TelegramCommand.text.rawValue] = ChatTypeHandler(service: service, bot: bot, type: .text).handle
        router[TelegramCommand.audio.rawValue] = ChatTypeHandler(service: service, bot: bot, type: .audio).handle

        router[.newChatMembers] = { context in
            guard let users = context.message?.newChatMembers else { return false }
            for user in users {
                guard user.id != self.bot.user.id else { continue }
                context.respondAsync("Welcome, \(user.firstName)!")
            }
            return true
        }

        router.unmatched = ChatHandler(service: service, bot: bot).handle
    }
    
    var decoder: JSONDecoder {
        get {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .secondsSince1970
            return decoder
        }
    }
    
    
    func reply(req: Request) async throws -> Vapor.Response {
        let content = try! req.content.decode(Update.self, using: decoder)
        try router.process(update: content)
        return Response(status :.ok)
    }
}


extension Update {
    enum CodingKeys: String, CodingKey {
        case updateId = "update_id"
    }
}
