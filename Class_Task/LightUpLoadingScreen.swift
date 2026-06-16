//
//  LightUpLoadingScreen.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 15/6/2026.
//
import SwiftUI

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

#Preview {
    NavigationStack {
        LightUpLoadingScreen()
    }
}
