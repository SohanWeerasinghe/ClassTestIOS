
//
//  LeaderboardView.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 16/6/2026.
//

import SwiftUI
import Charts

enum GameModeFilter: String, CaseIterable, Identifiable {
    case all = "All Games"
    case tapMe = "Tap Me!"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"
    
    var id: String { self.rawValue }
}

struct LeaderboardView: View {
    // Read the persisted high scores directly from device storage
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0
    @AppStorage("lightUpHighScore") private var lightUpHighScore: Int = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore: Int = 0
    
    // Read live history records matching Map metrics
    @StateObject private var sessionStore = GameSessionStore.shared
    @State private var selectedFilter: GameModeFilter = .all
    
    // Helper function to filter sessions based on segmented selection
    private var filteredSessions: [GameSession] {
        if selectedFilter == .all {
            return sessionStore.sessions
        } else {
            return sessionStore.sessions.filter { $0.gameName == selectedFilter.rawValue }
        }
    }
    
    // FIX: Isolating the calculation expression so the layout block doesn't crash the type-checker
    private var maximumScore: Int {
        filteredSessions.map { $0.score }.max() ?? 0
    }
    
    // Helper function to return thematic match colors
    private func colorForGame(_ name: String) -> Color {
        switch name {
        case "Tap Me!": return .orange
        case "Light It Up": return .green
        case "Quiz Rush": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        ZStack {
            Image("back2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Stats")
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(.black)
                        .fontDesign(.serif)
                    
                    Text("Your arcade analytics")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.top, 30)
                
                Picker("Select Game", selection: $selectedFilter) {
                    ForEach(GameModeFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 25)
                
                ScrollView {
                    VStack(spacing: 22) {
                        
                        // 1. DYNAMIC SUMMARY BLOCK (Totals & Bests)
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL GAMES")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.gray)
                                Text("\(filteredSessions.count)")
                                    .font(.title).bold()
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOP SCORE")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.gray)
                                Text("\(maximumScore)")
                                    .font(.title).bold()
                                    .foregroundColor(.purple)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        // 2. DYNAMIC BAR CHART COMPONENT
                        if !filteredSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Score Progress History")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Chart {
                                    ForEach(Array(filteredSessions.enumerated()), id: \.offset) { index, session in
                                        let gameLabel = "G\(index + 1)"
                                        let barColor = colorForGame(session.gameName)
                                        
                                        BarMark(
                                            x: .value("Game #", gameLabel),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(barColor)
                                        .cornerRadius(4)
                                    }
                                }
                                .frame(height: 180)
                                .padding(.top, 10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                        
                        // 3. CLASSIC HIGHSCORE CARDS
                        VStack(spacing: 12) {
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
                            
                            if selectedFilter == .all || selectedFilter == .quizRush {
                                LeaderboardCard(
                                    gameTitle: "Quiz Rush",
                                    highScore: quizRushHighScore,
                                    icon: "brain.head.profile",
                                    themeColor: .purple
                                )
                            }
                        }
                        
                        // 4. RECENT GAMES BREAKDOWN LIST
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Game Log")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if filteredSessions.isEmpty {
                                Text("No matches played yet under this filter.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 10)
                            } else {
                                ForEach(filteredSessions.reversed().prefix(5)) { session in
                                    HStack {
                                        Circle()
                                            .fill(colorForGame(session.gameName))
                                            .frame(width: 10, height: 10)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.gameName)
                                                .font(.subheadline).bold()
                                                .foregroundColor(.black)
                                            Text(session.date.formatted(date: .numeric, time: .shortened))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // FIX: Simplified the layout engine calculation signature down into a clean explicit String conversion to completely remove layout type timeouts
                                        Text(String(session.score) + " pts")
                                            .font(.system(.subheadline, design: .rounded)).bold()
                                            .foregroundColor(.black)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 5)
                }
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LeaderboardCard: View {
    let gameTitle: String
    let highScore: Int
    let icon: String
    let themeColor: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(themeColor)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(gameTitle)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                Text("Personal Best")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(highScore)")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(themeColor)
                
                Text("pts")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
