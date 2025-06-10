import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Data Models
struct CreateGameResponse: Codable {
    let game_id: String
}

struct GuessRequest: Codable {
    let game_id: String
    let guess: String
}

struct GuessResponse: Codable {
    let black: Int
    let white: Int
}

struct ErrorResponse: Codable {
    let error: String
}

// MARK: - API Client
class MastermindAPI {
    private let baseURL = "https://mastermind.darkube.app"
    
    func createGame() async throws -> String {
        guard let url = URL(string: "\(baseURL)/game") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            let gameResponse = try JSONDecoder().decode(CreateGameResponse.self, from: data)
            return gameResponse.game_id
        } else {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.serverError(errorResponse.error)
        }
    }
    
    func makeGuess(gameId: String, guess: String) async throws -> GuessResponse {
        guard let url = URL(string: "\(baseURL)/guess") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let guessRequest = GuessRequest(game_id: gameId, guess: guess)
        request.httpBody = try JSONEncoder().encode(guessRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(GuessResponse.self, from: data)
        } else {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw APIError.serverError(errorResponse.error)
        }
    }
    
    func deleteGame(gameId: String) async throws {
        guard let url = URL(string: "\(baseURL)/game/\(gameId)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 204 {
            throw APIError.serverError("Failed to delete game")
        }
    }
}

// MARK: - Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

enum GameError: Error, LocalizedError {
    case invalidInput
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input. Please enter a 4-digit code with numbers 1-6."
        case .networkError:
            return "Network error. Please check your internet connection."
        }
    }
}

// MARK: - Game Logic
class MastermindGame {
    private let api = MastermindAPI()
    private var gameId: String?
    private var attempts = 0
    private let maxAttempts = 10
    
    func start() async {
        print("🎯 Welcome to Mastermind!")
        print("Guess the 4-digit secret code. Each digit should be between 1-6.")
        print("After each guess, you'll receive:")
        print("B (Black): Correct digit in correct position")
        print("W (White): Correct digit in wrong position")
        print("Type 'exit' at any time to quit the game.\n")
        
        do {
            gameId = try await api.createGame()
            print("🎮 New game started! Game ID: \(gameId!)")
            await gameLoop()
        } catch {
            print("❌ Failed to start game: \(error.localizedDescription)")
        }
    }
    
    private func gameLoop() async {
        while attempts < maxAttempts {
            print("\n--- Attempt \(attempts + 1)/\(maxAttempts) ---")
            print("Enter your 4-digit guess (1-6): ", terminator: "")
            
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            
            if input.lowercased() == "exit" {
                await exitGame()
                return
            }
            
            guard isValidGuess(input) else {
                print("❌ Invalid input! Please enter exactly 4 digits, each between 1-6.")
                continue
            }
            
            do {
                guard let gameId = gameId else {
                    print("❌ Game not initialized")
                    return
                }
                
                let response = try await api.makeGuess(gameId: gameId, guess: input)
                attempts += 1
                
                displayResult(guess: input, response: response)
                
                if response.black == 4 {
                    print("🎉 Congratulations! You've cracked the code!")
                    await exitGame()
                    return
                }
                
                if attempts >= maxAttempts {
                    print("💀 Game Over! You've used all \(maxAttempts) attempts.")
                    print("Better luck next time!")
                    await exitGame()
                    return
                }
                
            } catch {
                print("❌ Error making guess: \(error.localizedDescription)")
                if error is APIError {
                    print("Please try again or type 'exit' to quit.")
                }
            }
        }
    }
    
    private func isValidGuess(_ guess: String) -> Bool {
        guard guess.count == 4 else { return false }
        
        for char in guess {
            guard let digit = Int(String(char)), digit >= 1 && digit <= 6 else {
                return false
            }
        }
        return true
    }
    
    private func displayResult(guess: String, response: GuessResponse) {
        print("\n🔍 Your guess: \(guess)")
        
        var feedback = ""
        // Add black pegs (correct position)
        for _ in 0..<response.black {
            feedback += "B"
        }
        // Add white pegs (wrong position)
        for _ in 0..<response.white {
            feedback += "W"
        }
        
        if feedback.isEmpty {
            feedback = "No matches"
        }
        
        print("📊 Result: \(feedback)")
        
        if response.black > 0 {
            print("✅ \(response.black) correct digit(s) in correct position")
        }
        if response.white > 0 {
            print("⚪ \(response.white) correct digit(s) in wrong position")
        }
        
        let totalCorrect = response.black + response.white
        if totalCorrect == 0 {
            print("❌ No correct digits found")
        }
    }
    
    private func exitGame() async {
        print("\n👋 Thanks for playing!")
        
        if let gameId = gameId {
            do {
                try await api.deleteGame(gameId: gameId)
                print("🗑️ Game session cleaned up.")
            } catch {
                print("⚠️ Warning: Failed to clean up game session")
            }
        }
        
        exit(0)
    }
}

// MARK: - Main Entry Point
Task {
    let game = MastermindGame()
    await game.start()
}

// Keep the program running
RunLoop.main.run()
