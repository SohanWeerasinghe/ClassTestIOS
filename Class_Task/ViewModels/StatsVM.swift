import SwiftUI
import Combine

enum GameModeFilter: String, CaseIterable, Identifiable {
    case all = "All Games"
    case tapMe = "Tap Me!"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { rawValue }
}

class StatsVM: ObservableObject {
    @Published var selectedFilter: GameModeFilter = .all
    
    func filteredSessions(from sessions: [GameSession]) -> [GameSession] {
        if selectedFilter == .all {
            return sessions
        }
        
        return sessions.filter { $0.gameName == selectedFilter.rawValue }
    }
    
    func maximumScore(from sessions: [GameSession]) -> Int {
        filteredSessions(from: sessions).map { $0.score }.max() ?? 0
    }
    
    func colorForGame(_ name: String) -> Color {
        if let mode = GameMode(rawValue: name) {
            return mode.color
        }
        
        return .gray
    }
}
