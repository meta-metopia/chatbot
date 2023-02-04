import Fluent
import Vapor

struct BloomChatbotController: RouteCollection {
    let service: ChatBotService
    
    struct ChatResponse: Content {
        var message: String
    }
    
    struct ChatUserWithMessage: Content {
        var from: ChatUser
        var message: String
    }
    
    init(service: ChatBotService) {
        self.service = service
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("chat", use: chat)
        routes.delete("chat", ":id", use: delete)
    }
    
    func delete(req: Request) async throws -> Response {
        let userId = req.parameters.get("id")
        guard let userId = userId else {
            throw Abort(.badRequest, reason: "parameter id not found")
        }
        try await service.clearHistory(userId: userId)
        return Response(status: .accepted)
    }
        
    
    func chat(req: Request) async throws -> ChatResponse {
        let message = try req.content.decode(ChatUserWithMessage.self)
        let response = try await service.replyTo(user: message.from, message.message)
        return ChatResponse(message: response)
    }
}
