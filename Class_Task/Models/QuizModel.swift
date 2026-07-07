import Foundation
internal import UIKit

struct QuizResponse: Codable {
    let results: [Question]
}

struct Question: Codable, Identifiable {
    var id: UUID { UUID() }
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

extension String {
    var decodedHTML: String {
        var text = self
        // Map of common HTML entities returned by Open Trivia DB
        let entities = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&rsquo;": "'",
            "&lsquo;": "'",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&deg;": "°"
        ]
        
        for (entity, replacement) in entities {
            text = text.replacingOccurrences(of: entity, with: replacement)
        }
        
        return text
    }
}
