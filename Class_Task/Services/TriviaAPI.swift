import Foundation

enum TriviaAPI {
    static func fetchQuestions(category: QuizCategory, difficulty: QuizDifficulty, amount: Int = 10) async throws -> [Question] {
        guard let url = questionURL(category: category, difficulty: difficulty, amount: amount) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decodedResponse.results
    }
    
    private static func questionURL(category: QuizCategory, difficulty: QuizDifficulty, amount: Int) -> URL? {
        var components = URLComponents(string: "https://opentdb.com/api.php")
        let safeAmount = min(max(amount, 1), 50)
        var queryItems = [
            URLQueryItem(name: "amount", value: String(safeAmount)),
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
