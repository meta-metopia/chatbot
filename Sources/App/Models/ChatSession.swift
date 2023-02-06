import Fluent
import Vapor
import TelegramBotSDK

protocol ChatSessionProtocol: MessageProtocol {
    var user: ChatUser { get set }
    var history: String? { get set }
}

struct CreateChatSessionDto: ChatSessionProtocol {
    var user: ChatUser
    
    var history: String?
}

enum ChatType: String, Codable {
    case audio
    case text
}


final class ChatSession: Model, Content, ChatSessionProtocol {
    static let schema = "chat-session"
    
    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user")
    var user: ChatUser
    
    @OptionalField(key: "history")
    var history: String?
    
    @Field(key: "type")
    var chatType: ChatType

    init() { }
    
    init(history: String?, chatType: ChatType) {
        self.history = history
        self.chatType = chatType
    }
}
