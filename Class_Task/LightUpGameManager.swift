//
//  LightUpGameManager.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 16/6/2026.
//
import SwiftUI
import Combine

// 1. Model the Individual Grid Card Data Structure
struct LightUpCard: Identifiable {
    let id: Int
    var isLit: Bool = false
}

// 2. Map Assignment Specifications for Levels 1 - 4
enum GameLevel: Int, CaseIterable {
    case L1 = 1
    case L2
    case L3
    case L4
    
    var gridCount: Int {
        switch self {
        case .L1: return 3   // 3 cards (row)
        case .L2: return 4   // 4 cards
        case .L3: return 6   // 6 cards (2x3)
        case .L4: return 9   // 9 cards (3x3)
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

// 3. Game Engine Logic Controller
class LightUpGameManager: ObservableObject {
    @Published var cards: [LightUpCard] = []
    @Published var currentLevel: GameLevel = .L1
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var timeRemaining: Int = 60
    @Published var isGameOver: Bool = false
    @Published var showLevelUpFlash: Bool = false
    
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
        
        // Main game clock ticking down from 60 seconds
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
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showLevelUpFlash = false
            }
        }
    }
    
    private func triggerRandomLightUp() {
        guard !isGameOver && !cards.isEmpty else { return }
        
        // Turn off all currently lit cards
        for i in 0..<cards.count {
            cards[i].isLit = false
        }
        
        if currentLevel == .L4 {
            // Level 4 requires 2 cards lit simultaneously
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
            // Levels 1-3 require 1 active lit card
            let randomIndex = Int.random(in: 0..<cards.count)
            cards[randomIndex].isLit = true
        }
    }
    
    func handleCardTap(id: Int) {
        guard !isGameOver else { return }
        
        if let index = cards.firstIndex(where: { $0.id == id }) {
            if cards[index].isLit {
                // Correct Hit
                score += 10
                cards[index].isLit = false // Immediately dim it
                triggerRandomLightUp()     // Move along to next target cycle
            } else {
                // Incorrect Hit Penalty: Assignment specifies 3-Lives System option
                handlePenalty()
            }
        }
    }
    
    private func handlePenalty() {
        if lives > 1 {
            lives -= 1
        } else {
            lives = 0
            endGame()
        }
    }
    
    private func endGame() {
        isGameOver = true
        gameTimer?.cancel()
        lightWindowTimer?.cancel()
    }
}
