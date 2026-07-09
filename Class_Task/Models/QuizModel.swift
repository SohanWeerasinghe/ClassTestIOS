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

enum QuizCategory: Int, CaseIterable, Identifiable {
    case any = 0
    case generalKnowledge = 9
    case books = 10
    case film = 11
    case music = 12
    case musicalsAndTheatres = 13
    case television = 14
    case videoGames = 15
    case boardGames = 16
    case scienceAndNature = 17
    case computers = 18
    case mathematics = 19
    case mythology = 20
    case sports = 21
    case geography = 22
    case history = 23
    case politics = 24
    case art = 25
    case celebrities = 26
    case animals = 27
    case vehicles = 28
    case comics = 29
    case gadgets = 30
    case animeAndManga = 31
    case cartoonsAndAnimations = 32
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .any: return "Any Category"
        case .generalKnowledge: return "General Knowledge"
        case .books: return "Entertainment: Books"
        case .film: return "Entertainment: Film"
        case .music: return "Entertainment: Music"
        case .musicalsAndTheatres: return "Entertainment: Musicals & Theatres"
        case .television: return "Entertainment: Television"
        case .videoGames: return "Entertainment: Video Games"
        case .boardGames: return "Entertainment: Board Games"
        case .scienceAndNature: return "Science & Nature"
        case .computers: return "Science: Computers"
        case .mathematics: return "Science: Mathematics"
        case .mythology: return "Mythology"
        case .sports: return "Sports"
        case .geography: return "Geography"
        case .history: return "History"
        case .politics: return "Politics"
        case .art: return "Art"
        case .celebrities: return "Celebrities"
        case .animals: return "Animals"
        case .vehicles: return "Vehicles"
        case .comics: return "Entertainment: Comics"
        case .gadgets: return "Science: Gadgets"
        case .animeAndManga: return "Entertainment: Japanese Anime & Manga"
        case .cartoonsAndAnimations: return "Entertainment: Cartoon & Animations"
        }
    }
    
    static var randomPlayable: QuizCategory {
        QuizCategory.allCases.filter { $0 != .any }.randomElement() ?? .generalKnowledge
    }
}

enum QuizDifficulty: String, CaseIterable, Identifiable {
    case any = ""
    case easy
    case medium
    case hard
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .any: return "Any Difficulty"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    static var randomPlayable: QuizDifficulty {
        [.easy, .medium, .hard].randomElement() ?? .medium
    }
}

extension String {
    var decodedHTML: String {
        var text = self
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
