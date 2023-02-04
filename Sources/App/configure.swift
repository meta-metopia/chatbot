import Fluent
import FluentMongoDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    try await setupWebhook(app: app)
    try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL")!
    ), as: .mongo)

    app.migrations.add(CreateSessions())

    // register routes
    try routes(app)
}


func setupWebhook(app: Application) async throws {
    guard let baseWebhookURL = Environment.get("TELEGRAM_WEBHOOK_URL") else {
        throw TelegramErrors.missingKey("TELEGRAM_WEBHOOK_URL")
    }
    
    guard let apiKey = Environment.get("TELEGRAM_KEY") else {
        throw TelegramErrors.missingKey("TELEGRAM_KEY")
    }
    
    let uri = "webhook/\(apiKey)"
    let webhookURL = "\(baseWebhookURL)/\(uri)"
    
    let webhookRequestURL = URI.init(stringLiteral: "\(telegramAPI)/bot\(apiKey)/setWebhook?url=\(webhookURL)")
    
    app.logger.info("Sending webhook request to \(webhookRequestURL)")
    _ = try await app.client.get(webhookRequestURL)
}
