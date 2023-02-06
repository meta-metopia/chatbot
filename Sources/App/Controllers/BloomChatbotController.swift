import Fluent
import Vapor

struct BloomChatbotController: RouteCollection {
    let service: ChatBotService
    
    struct ChatResponse: Content {
        var message: String
        var audioURL: String?
    }
    
    struct ChatUserWithMessage: Content {
        var from: ChatUser
        var message: String
    }
    
    struct UpdateChatTypeRequest: Content {
        var user: ChatUser
        var type: ChatType
    }
    
    init(service: ChatBotService) {
        self.service = service
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("chat", use: chat)
        routes.delete("chat", ":id", use: delete)
        routes.patch("chat", "type", use: updateChatType)
    }
    
    func updateChatType(req: Request) async throws -> Response {
        let content = try req.content.decode(UpdateChatTypeRequest.self)
        try await service.updateChatSessionType(user: content.user, type: content.type)
        
        return Response(status: .ok)
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
        let response = try await service.replyTo(user: message.from, message.message, shouldUpload: true)
        req.logger.debug("Sending request back...")
        return ChatResponse(message: response.text, audioURL: response.audioURL?.absoluteString)
    }
}
