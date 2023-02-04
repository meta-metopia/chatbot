//
//  File.swift
//  
//
//  Created by Qiwei Li on 2/4/23.
//

import Foundation
import Vapor
import Alamofire

enum BloomChatErrors: LocalizedError {
    case missingKeys(key: String)
    case saveBeforeLoad
    case noBotResponse
    
    var errorDescription: String? {
        switch self {
            case .missingKeys(let key):
                return "Missing required key: \(key)"
            case .saveBeforeLoad:
                return "Calling save before loading"
            case .noBotResponse:
                return "No bot response"
        }
    }
}

struct BloomResponse: MessageProtocol, Codable {
    let generated_text: String
}


class BloomChatbot: ChatbotClientProtocol {
    typealias Message = ChatSession
    typealias User = ChatUser
    typealias RawResponse = BloomResponse
    
    let apikey: String
    let endpoint: String
    let prePromptURL = Bundle.module.url(forResource: "bloom-bot-polite-prepromt", withExtension: ".md")
    let prePrompt: String
    let logger = Logger(label: "bloom.chatbot")
    
    var user: User?
    var previous: Message?
    var response: String?
    var userMessage: String?
    
    init() throws {
        guard let apiKey = Environment.get("BLOOM_API_KEY") else {
            throw BloomChatErrors.missingKeys(key: "BLOOM_API_KEY")
        }
        
        guard let endpoint = Environment.get("BLOOM_ENDPOINT") else {
            throw BloomChatErrors.missingKeys(key: "BLOOM_ENDPOINT")
        }
        
        self.apikey = apiKey
        self.endpoint = endpoint
        prePrompt = try! String(contentsOf: prePromptURL!)
    }
    
    func sendRaw(_ message: String) async throws -> [BloomResponse] {
        let body = ["inputs": message]
        let headers: Alamofire.HTTPHeaders = [.authorization(bearerToken: apikey)]
        let task = AF.request(endpoint ,method: .post, parameters: body,encoding: JSONEncoding.default ,headers: headers).serializingDecodable([BloomResponse].self)
        let result = try await task.value
        return result
    }
    
    func sendMessage(_ message: String) async throws -> String {
        let prompt = preparePromptForBot(previous: previous?.history, userMessage: message)
        logger.debug("Prompt: \(prompt.replacingOccurrences(of: self.prePrompt, with: ""))")
        let result = try await sendRaw(prompt)
        logger.debug("Result: \(result[0])")
        let response = try getBotResponse(from: result.first?.generated_text, userMessage: message, history: previous?.history)
        self.response = response
        self.userMessage = message
        return response
    }
    
    func save() async throws -> ChatSession {
        guard let _ = user else {
            throw BloomChatErrors.saveBeforeLoad
        }
        
        guard let response = response else {
            throw BloomChatErrors.noBotResponse
        }
        
        guard let userMessage = userMessage else {
            throw BloomChatErrors.saveBeforeLoad
        }
        
        let newHistory = combineHistoryForDatabase(previous: previous?.history, response: response, userMessage: userMessage)
        return ChatSession(history: newHistory)
    }
    
    func load(message: ChatSession?, for user: ChatUser) async throws {
        self.previous = message
        self.user = user
    }
    
    func onDestory() {
        self.previous = nil
        self.user = nil
        self.response = nil
    }
}

extension BloomChatbot {
    /**
     Prepare prompt for bot
     */
    private func preparePromptForBot(previous: String?, userMessage: String) -> String {
        var content = ""
        if let previous = previous {
            content = "\(previous)\nUser: \(userMessage)\nBot: "
        } else {
            content =  "User: \(userMessage)\nBot: "
        }
        return "\(self.prePrompt)\n\(content)"
    }
    
    /**
     Combine the history with user message, bot response
     */
    private func combineHistoryForDatabase(previous: String?, response: String, userMessage: String) -> String {
        var history: String = ""
        if let previous = previous {
            history =  "\(previous)\nUser: \(userMessage)\nBot: \(response)"
        } else {
            history =  "User: \(userMessage)\nBot: \(response)"
        }
        return history
    }
    
    /**
     * Always returns the first bot response next to the user's userMessage
     * For example Given the userMessage is Hi.
     * User: Hi
     * Bot: Hi
     * User: How are you
     * Bot: I am good
     *
     * Will return Hi.
     */
    private func getBotResponse(from response: String?, userMessage: String, history: String?) throws -> String {
        guard let response = response else { return "Error!" }
        let responseLines = response.replacingOccurrences(of: prePrompt, with: "").replacingOccurrences(of: history ?? "", with: "").replacingOccurrences(of: "User: \(userMessage)", with: "").components(separatedBy: "\n").filter({!$0.isEmpty})
        for (_, line) in responseLines.enumerated() {
            if line.hasPrefix("Bot") {
                return line.replacingOccurrences(of: "Bot: ", with: "")
            }
        }
        
        throw BloomChatErrors.noBotResponse
    }
    
}
