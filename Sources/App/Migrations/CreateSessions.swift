import Fluent

struct CreateSessions: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ChatUser.schema)
            .id()
            .unique(on: "userId")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ChatUser.schema).delete()
    }
}
