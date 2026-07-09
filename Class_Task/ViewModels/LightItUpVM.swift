import SwiftUI
import Combine
import AVFAudio
internal import UIKit

struct LightUpCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    var gridCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    var litDuration: TimeInterval {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    var columns: [GridItem] {
        switch self {
        case .L1: return Array(repeating: GridItem(.flexible()), count: 3)
        case .L2: return Array(repeating: GridItem(.flexible()), count: 2)
        case .L3: return Array(repeating: GridItem(.flexible()), count: 3)
        case .L4: return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }
    
    var glowColor: Color {
        switch self {
        case .L1: return .green
        case .L2: return .blue
        case .L3: return .orange
        case .L4: return .purple
        }
    }
}

class LightUpGameManager: ObservableObject {
    @Published var cards: [LightUpCard] = []
    @Published var currentLevel: GameLevel = .L1
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var timeRemaining: Int = 60
    @Published var isGameOver: Bool = false
    @Published var showLevelUpFlash: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private var gameTimer: AnyCancellable?
    private var lightWindowTimer: AnyCancellable?
    private var roundTimeElapsed: Int = 0
    
    func startGame() {
        score = 0
        lives = 3
        timeRemaining = 60
        roundTimeElapsed = 0
        currentLevel = .L1
        isGameOver = false
        
        generateGrid()
        startTimers()
        triggerRandomLightUp()
    }
    
    private func generateGrid() {
        cards = (0..<currentLevel.gridCount).map { LightUpCard(id: $0) }
    }
    
    private func startTimers() {
        gameTimer?.cancel()
        lightWindowTimer?.cancel()
        
        gameTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickGameClock()
            }
        
        resetLightWindowTimer()
    }
    
    private func resetLightWindowTimer() {
        lightWindowTimer?.cancel()
        
        lightWindowTimer = Timer.publish(every: currentLevel.litDuration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.triggerRandomLightUp()
            }
    }
    
    private func tickGameClock() {
        guard !isGameOver else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            roundTimeElapsed += 1
            checkLevelProgression()
        } else {
            endGame()
        }
    }
    
    private func playSound(filename: String, ext: String) {
        guard let path = Bundle.main.path(forResource: filename, ofType: ext) else {
            print("Error: \(filename).\(ext) file not found in main project bundle.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Audio error: \(error.localizedDescription)")
        }
    }
    
    func playLevelCompleteSound() {
        playSound(filename: "levelcompleted", ext: "wav")
    }
    
    func playHealthLoseSound() {
        playSound(filename: "losehealth", ext: "wav")
    }
    
    func playGameOverSound() {
        playSound(filename: "gameoverarcade", ext: "mp3")
    }
    
    private func checkLevelProgression() {
        let newLevel: GameLevel
        
        if roundTimeElapsed < 15 {
            newLevel = .L1
        } else if roundTimeElapsed < 30 {
            newLevel = .L2
        } else if roundTimeElapsed < 45 {
            newLevel = .L3
        } else {
            newLevel = .L4
        }
        
        if newLevel != currentLevel {
            withAnimation(.easeInOut) {
                currentLevel = newLevel
                showLevelUpFlash = true
                generateGrid()
                resetLightWindowTimer()
                playLevelCompleteSound()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showLevelUpFlash = false
            }
        }
    }
    
    private func triggerRandomLightUp() {
        guard !isGameOver && !cards.isEmpty else { return }
        
        for index in 0..<cards.count {
            cards[index].isLit = false
        }
        
        if currentLevel == .L4 {
            let firstRandomIndex = Int.random(in: 0..<cards.count)
            var secondRandomIndex = Int.random(in: 0..<cards.count)
            
            if cards.count > 1 {
                while secondRandomIndex == firstRandomIndex {
                    secondRandomIndex = Int.random(in: 0..<cards.count)
                }
                cards[firstRandomIndex].isLit = true
                cards[secondRandomIndex].isLit = true
            } else {
                cards[firstRandomIndex].isLit = true
            }
        } else {
            let randomIndex = Int.random(in: 0..<cards.count)
            cards[randomIndex].isLit = true
        }
    }
    
    func handleCardTap(id: Int) {
        guard !isGameOver else { return }
        
        if let index = cards.firstIndex(where: { $0.id == id }) {
            if cards[index].isLit {
                score += 10
                cards[index].isLit = false
                triggerRandomLightUp()
            } else {
                handlePenalty()
            }
        }
    }
    
    private func handlePenalty() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        if lives > 1 {
            lives -= 1
            playHealthLoseSound()
        } else {
            lives = 0
            endGame()
            playGameOverSound()
        }
    }
    
    private func endGame() {
        guard !isGameOver else { return }
        
        isGameOver = true
        GameSessionStore.shared.addSession(
            gameName: GameMode.lightItUp.title,
            score: score,
            location: LocationService.shared.currentLocation
        )
        gameTimer?.cancel()
        lightWindowTimer?.cancel()
    }
}
