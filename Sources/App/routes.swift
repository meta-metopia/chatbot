import Fluent
import Vapor

func routes(_ app: Application) throws {
    let bloomChat = try BloomChatbot()
    let chatbotService = ChatBotService(client: bloomChat, db: app.db)
    
    try app.register(collection: BloomChatbotController(service: chatbotService))
    try app.register(collection: TelegramController(service: chatbotService))
}
