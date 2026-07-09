import Foundation

enum TriviaAPI {
    static func fetchQuestions(category: QuizCategory, difficulty: QuizDifficulty) async throws -> [Question] {
        guard let url = questionURL(category: category, difficulty: difficulty) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decodedResponse.results
    }
    
    private static func questionURL(category: QuizCategory, difficulty: QuizDifficulty) -> URL? {
        var components = URLComponents(string: "https://opentdb.com/api.php")
        var queryItems = [
            URLQueryItem(name: "amount", value: "10"),
            URLQueryItem(name: "type", value: "multiple")
        ]
        
        if category != .any {
            queryItems.append(URLQueryItem(name: "category", value: String(category.rawValue)))
        }
        
        if difficulty != .any {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        
        components?.queryItems = queryItems
        return components?.url
    }
}
