//
//  LightItUp.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 15/6/2026.
//

import SwiftUI

struct LightItUpView: View {
    @StateObject private var gameManager = LightUpGameManager()
    @AppStorage("lightUpHighScore") private var highScore: Int = 0
    @State private var madeNewHighScore = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 10/255, green: 12/255, blue: 20/255), Color(red: 18/255, green: 24/255, blue: 38/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white.opacity(0.65))
                        Text("\(gameManager.score)")
                            .font(.title).bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Text("LEVEL")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white.opacity(0.65))
                        Text("\(gameManager.currentLevel.rawValue)")
                            .font(.title).bold()
                            .foregroundColor(gameManager.currentLevel.glowColor)
                            .shadow(color: gameManager.currentLevel.glowColor.opacity(0.7), radius: 6)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("TIME")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white.opacity(0.65))
                        Text("\(gameManager.timeRemaining)s")
                            .font(.title).bold()
                            .foregroundColor(gameManager.timeRemaining <= 5 ? .red : .white)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.75))
                .cornerRadius(15)
                .padding(.horizontal)
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < gameManager.lives ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
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
                    ResultView(
                        title: "Game Over",
                        gameName: "Light It Up",
                        score: gameManager.score,
                        bestScore: max(gameManager.score, highScore),
                        isNewHighScore: madeNewHighScore,
                        themeColor: gameManager.currentLevel.glowColor
                    ) {
                        saveHighScoreIfNeeded()
                        madeNewHighScore = false
                        gameManager.startGame()
                    }
                }
                
                Spacer()
            }
            
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
        .preferredColorScheme(.dark)
        .onAppear {
            gameManager.startGame()
        }
        .onChange(of: gameManager.isGameOver) {
            if gameManager.isGameOver {
                madeNewHighScore = gameManager.score > highScore
                saveHighScoreIfNeeded()
            }
        }
        .onDisappear {
            saveHighScoreIfNeeded()
        }
    }
    
    private func saveHighScoreIfNeeded() {
        if gameManager.score > highScore {
            highScore = gameManager.score
        }
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
