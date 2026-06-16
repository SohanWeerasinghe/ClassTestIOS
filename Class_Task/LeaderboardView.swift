//
//  LeaderboardView.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 16/6/2026.

import SwiftUI

enum GameModeFilter: String, CaseIterable, Identifiable {
    case all = "All Games"
    case tapMe = "Tap Me!"
    case lightItUp = "Light It Up"
    
    var id: String { self.rawValue }
}

struct LeaderboardView: View {
    // Read the persisted high scores directly from device storage
    // These keys match the @AppStorage keys used inside your games
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0 // Make sure this matches your Week 1 key if different
    @AppStorage("lightUpHighScore") private var lightUpHighScore: Int = 0
    
    @State private var selectedFilter: GameModeFilter = .all
    
    var body: some View {
        ZStack {
            // Background Theme
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Custom Segmented Filter Control
                Picker("Select Game", selection: $selectedFilter) {
                    ForEach(GameModeFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Scores Display List
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedFilter == .all || selectedFilter == .tapMe {
                            LeaderboardCard(
                                gameTitle: "Tap Me!",
                                highScore: tapMeHighScore,
                                icon: "hand.tap.fill",
                                themeColor: .orange
                            )
                        }
                        
                        if selectedFilter == .all || selectedFilter == .lightItUp {
                            LeaderboardCard(
                                gameTitle: "Light It Up",
                                highScore: lightUpHighScore,
                                icon: "gamecontroller.fill",
                                themeColor: .green
                            )
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationTitle("Leaderboard 🏆")
        .navigationBarTitleDisplayMode(.large)
    }
}

// Reusable card component for displaying scores
struct LeaderboardCard: View {
    let gameTitle: String
    let highScore: Int
    let icon: String
    let themeColor: Color
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon Badge
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 55, height: 55)
                .background(themeColor)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(gameTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Personal Best")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Score Display
            VStack(alignment: .trailing) {
                Text("\(highScore)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(themeColor)
                Text("pts")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
