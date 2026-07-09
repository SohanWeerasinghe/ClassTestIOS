import SwiftUI

enum GameMode: String, CaseIterable, Identifiable, Codable {
    case tapMe = "Tap Me!"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var icon: String {
        switch self {
        case .tapMe: return "hand.tap.fill"
        case .lightItUp: return "gamecontroller.fill"
        case .quizRush: return "brain.head.profile"
        }
    }
    
    var color: Color {
        switch self {
        case .tapMe: return .orange
        case .lightItUp: return .green
        case .quizRush: return .purple
        }
    }
}
