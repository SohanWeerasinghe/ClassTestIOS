//
//  LightUpLoadingScreen.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 15/6/2026.
//

import SwiftUI
import Combine
import AVFAudio

//Main Game View
struct LightUpLoadingScreen: View {
    @StateObject private var gameManager = LightUpGameManager()
    @AppStorage("lightUpHighScore") private var highScore: Int = 0
    
    var body: some View {
        ZStack {
            // Game Area Theme Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top Status Scoreboards Panel View
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameManager.score)")
                            .font(.title).bold()
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Text("LEVEL")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameManager.currentLevel.rawValue)")
                            .font(.title).bold()
                            .foregroundColor(gameManager.currentLevel.glowColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("TIME")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(gameManager.timeRemaining)s")
                            .font(.title).bold()
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Hearts Lives View Tracker
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < gameManager.lives ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                // Dynamic Play Grid Container Area
                if !gameManager.isGameOver {
                    LazyVGrid(columns: gameManager.currentLevel.columns, spacing: 16) {
                        ForEach(gameManager.cards) { card in
                            Button(action: {
                                gameManager.handleCardTap(id: card.id)
                            }) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(card.isLit ? gameManager.currentLevel.glowColor : Color.gray.opacity(0.3))
                                    .frame(height: 110)
                                    .shadow(color: card.isLit ? gameManager.currentLevel.glowColor.opacity(0.6) : .clear, radius: 10)
                                    .scaleEffect(card.isLit ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: card.isLit)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                } else {
                    // Final Game End Score Display overlay panel
                    VStack(spacing: 16) {
                        Text("Game Over 🏁")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Final Score: \(gameManager.score)")
                            .font(.title2)
                        
                        if gameManager.score > highScore {
                            Text("🎉 New High Score! 🎉")
                                .foregroundColor(.green)
                                .bold()
                        }
                        
                        Text("Best Score: \(max(gameManager.score, highScore))")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            if gameManager.score > highScore {
                                highScore = gameManager.score
                            }
                            gameManager.startGame()
                        }) {
                            Text("Play Again")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                }
                
                Spacer()
            }
            
            // Level Up Transient Screen Flash Notification Mask Modifier Overlay
            if gameManager.showLevelUpFlash {
                Color(gameManager.currentLevel.glowColor)
                    .opacity(0.25)
                    .ignoresSafeArea()
                    .overlay(
                        Text("LEVEL UP!")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                    )
                    .transition(.opacity)
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            gameManager.startGame()
        }
        .onDisappear {
            if gameManager.score > highScore {
                highScore = gameManager.score
            }
        }
    }
}

// Individual Card Model
struct LightUpCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

// Game Levels Setup
enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    var gridCount: Int {
        switch self {
        case .L1: return 3   // 3 cards in a row
        case .L2: return 4   // 4 cards grid
        case .L3: return 6   // 6 cards (2x3 grid)
        case .L4: return 9   // 9 cards (3x3 grid)
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
        
        // Main game clock (60 seconds countdown)
        gameTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickGameClock()
            }
            
        resetLightWindowTimer()
    }
    
    private func resetLightWindowTimer() {
        lightWindowTimer?.cancel()
        
        // Repeats based on how fast cards should switch for the current level
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
    
    // Core helper to handle audio loading cleanly without duplicate code
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
        
        // Changes the level depending on how long the game has been running
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
            
            // Turn off level up flash banner screen after 0.5s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showLevelUpFlash = false
            }
        }
    }
    
    private func triggerRandomLightUp() {
        guard !isGameOver && !cards.isEmpty else { return }
        
        // Dim all cards first
        for index in 0..<cards.count {
            cards[index].isLit = false
        }
        
        if currentLevel == .L4 {
            // Level 4 lights up 2 random cards at the same time
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
            // Levels 1-3 only light up 1 card at a time
            let randomIndex = Int.random(in: 0..<cards.count)
            cards[randomIndex].isLit = true
        }
    }
    
    func handleCardTap(id: Int) {
        guard !isGameOver else { return }
        
        if let index = cards.firstIndex(where: { $0.id == id }) {
            if cards[index].isLit {
                // Correct tap: update score, dim card, and show next target instantly
                score += 10
                cards[index].isLit = false
                triggerRandomLightUp()
            } else {
                // Incorrect tap penalty
                handlePenalty()
            }
        }
    }
    
    private func handlePenalty() {
            // Trigger a heavy physical haptic pulse on the phone engine
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
        isGameOver = true
        gameTimer?.cancel()
        lightWindowTimer?.cancel()
    }
}

#Preview {
    NavigationStack {
        LightUpLoadingScreen()
    }
}
