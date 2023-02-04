import Fluent
import Vapor
import TelegramBotSDK

protocol ChatSessionProtocol: MessageProtocol {
    var user: ChatUser { get set }
    var history: String { get set }
}

struct CreateChatSessionDto: ChatSessionProtocol {
    var user: ChatUser
    
    var history: String
}


final class ChatSession: Model, Content, ChatSessionProtocol {
    static let schema = "chat-session"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user")
    var user: ChatUser
    
    @Field(key: "history")
    var history: String

    init() { }
    
    init(history: String) {
        self.history = history
    }
}
