import Foundation
import CoreLocation
import Combine

struct GameSession: Identifiable, Codable {
    let id: UUID
    let gameName: String
    let score: Int
    let date: Date
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    
    init(id: UUID, gameName: String, score: Int, date: Date, latitude: Double, longitude: Double, accuracy: Double) {
        self.id = id
        self.gameName = gameName
        self.score = score
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case gameName
        case score
        case date
        case latitude
        case longitude
        case accuracy
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        gameName = try container.decode(String.self, forKey: .gameName)
        score = try container.decode(Int.self, forKey: .score)
        date = try container.decode(Date.self, forKey: .date)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        accuracy = try container.decodeIfPresent(Double.self, forKey: .accuracy) ?? 0
    }
}

class GameSessionStore: ObservableObject {
    static let shared = GameSessionStore()
    
    @Published var sessions: [GameSession] = []
    
    private let storageKey = "gameSessions"
    
    private init() {
        loadSessions()
    }
    
    func addSession(gameName: String, score: Int, location: CLLocation?) {
        let hasUsableLocation = location.map {
            $0.horizontalAccuracy > 0 && $0.horizontalAccuracy <= 100
        } ?? false
        
        let newSession = GameSession(
            id: UUID(),
            gameName: gameName,
            score: score,
            date: Date(),
            latitude: hasUsableLocation ? location?.coordinate.latitude ?? 0 : 0,
            longitude: hasUsableLocation ? location?.coordinate.longitude ?? 0 : 0,
            accuracy: hasUsableLocation ? location?.horizontalAccuracy ?? 0 : 0
        )
        
        sessions.append(newSession)
        saveSessions()
    }
    
    func clearSessions() {
        sessions.removeAll()
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
