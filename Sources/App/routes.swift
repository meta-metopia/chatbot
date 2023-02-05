import Fluent
import Vapor

func routes(_ app: Application) throws {
    let bloomChat = try BloomChatbot(client: app.client)
    let chatbotService = ChatBotService(client: bloomChat, db: app.db)
    
    try app.register(collection: BloomChatbotController(service: chatbotService))
    try app.register(collection: TelegramController(service: chatbotService))
}
