import Fluent
import Vapor

func routes(_ app: Application) async throws {
    guard let speechKey = Environment.get("AZURE_SPEECH_KEY") else {
        throw BloomChatErrors.missingKeys(key: "AZURE_SPEECH_KEY")
    }
    
    let bloomChat = try BloomChatbot(client: app.client)
    let speechClient = AzureTextToSpeechClient(resourceKey: speechKey)
    let s3Client = try S3FileClient()
    let chatbotService = ChatBotService(client: bloomChat, db: app.db, speech: speechClient, s3Client: s3Client)
    
    try await chatbotService.setup()
    
    try app.register(collection: BloomChatbotController(service: chatbotService))
    try app.register(collection: TelegramController(service: chatbotService))
}
