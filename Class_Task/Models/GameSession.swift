import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let gameName: String
    let score: Int
    let date: Date
    let latitude: Double
    let longitude: Double
}

class GameSessionStore: ObservableObject {
    static let shared = GameSessionStore()
    
    @Published var sessions: [GameSession] = []
    
    private let storageKey = "gameSessions"
    
    private init() {
        loadSessions()
    }
    
    func addSession(gameName: String, score: Int, location: CLLocation?) {
        let coordinate = location?.coordinate ?? CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
        
        let newSession = GameSession(
            id: UUID(),
            gameName: gameName,
            score: score,
            date: Date(),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        sessions.append(newSession)
        saveSessions()
    }
    
    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        
        if let decodedSessions = try? JSONDecoder().decode([GameSession].self, from: data) {
            sessions = decodedSessions
        }
    }
    
    private func saveSessions() {
        if let encodedSessions = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encodedSessions, forKey: storageKey)
        }
    }
}
