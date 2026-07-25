//
//  StatsTab.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 7/7/2026.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0
    @AppStorage("lightUpHighScore") private var lightUpHighScore: Int = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore: Int = 0
    
    @StateObject private var sessionStore = GameSessionStore.shared
    @StateObject private var statsVM = StatsVM()
    
    private var filteredSessions: [GameSession] {
        statsVM.filteredSessions(from: sessionStore.sessions)
    }
    
    private var maximumScore: Int {
        statsVM.maximumScore(from: sessionStore.sessions)
    }
    
    // Background Color
    private let darkBackground = Color(red: 13/255, green: 15/255, blue: 23/255)
    
    var body: some View {
        ZStack {
            // Main Dark Background
            darkBackground
                .ignoresSafeArea()
            
            // Neon Glow Effects
            RadialGradient(
                colors: [Color.cyan.opacity(0.18), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.purple.opacity(0.18), Color.clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 18) {
                
                // Page Header
                VStack(spacing: 6) {
                    Text("ARCADE ANALYTICS")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                        .tracking(3)
                    
                    Text("Stats & Logs")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.4), radius: 8, x: 0, y: 0)
                    
                    Text("Your performance history & high scores")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                .padding(.top, 16)
                
                // Game Mode Picker Filter
                Picker("Select Game", selection: $statsVM.selectedFilter) {
                    ForEach(GameModeFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                // Main Content Scroll Area
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        
                        // Top Summary Cards (Total Games and High Score)
                        HStack(spacing: 14) {
                            
                            // Card 1: Total Games
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL GAMES")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .tracking(1)
                                
                                Text("\(filteredSessions.count)")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                            
                            // Card 2: Top Score
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOP SCORE")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(Color.cyan.opacity(0.8))
                                    .tracking(1)
                                
                                Text("\(maximumScore)")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.cyan)
                                    .shadow(color: .cyan.opacity(0.5), radius: 6, x: 0, y: 0)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Chart Section
                        if !filteredSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Score Progress History")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Chart {
                                    ForEach(Array(filteredSessions.enumerated()), id: \.offset) { index, session in
                                        BarMark(
                                            x: .value("Game #", "G\(index + 1)"),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(statsVM.colorForGame(session.gameName))
                                        .cornerRadius(6)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                                            .foregroundStyle(Color.white.opacity(0.15))
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel()
                                            .foregroundStyle(Color.white.opacity(0.5))
                                    }
                                }
                                .frame(height: 180)
                                .padding(.top, 8)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Score Badges List
                        VStack(spacing: 12) {
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .tapMe {
                                ScoreBadge(
                                    gameTitle: GameMode.tapMe.title,
                                    highScore: tapMeHighScore,
                                    icon: GameMode.tapMe.icon,
                                    themeColor: GameMode.tapMe.color
                                )
                            }
                            
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .lightItUp {
                                ScoreBadge(
                                    gameTitle: GameMode.lightItUp.title,
                                    highScore: lightUpHighScore,
                                    icon: GameMode.lightItUp.icon,
                                    themeColor: GameMode.lightItUp.color
                                )
                            }
                            
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .quizRush {
                                ScoreBadge(
                                    gameTitle: GameMode.quizRush.title,
                                    highScore: quizRushHighScore,
                                    icon: GameMode.quizRush.icon,
                                    themeColor: GameMode.quizRush.color
                                )
                            }
                        }
                        
                        // Recent Games Log Box
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Recent Game Log")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if filteredSessions.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 6) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color.white.opacity(0.3))
                                        
                                        Text("No matches played yet under this filter.")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color.white.opacity(0.5))
                                    }
                                    .padding(.vertical, 16)
                                    Spacer()
                                }
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(Array(filteredSessions.reversed().prefix(5).enumerated()), id: \.element.id) { index, session in
                                        VStack(spacing: 10) {
                                            HStack {
                                                Circle()
                                                    .fill(statsVM.colorForGame(session.gameName))
                                                    .frame(width: 8, height: 8)
                                                    .shadow(color: statsVM.colorForGame(session.gameName).opacity(0.8), radius: 4, x: 0, y: 0)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(session.gameName)
                                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                                        .foregroundColor(.white)
                                                    
                                                    Text(session.date.formatted(date: .numeric, time: .shortened))
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundColor(Color.white.opacity(0.5))
                                                }
                                                
                                                Spacer()
                                                
                                                Text("\(session.score) pts")
                                                    .font(.system(size: 14, weight: .black, design: .rounded))
                                                    .foregroundColor(.cyan)
                                            }
                                            
                                            if index < min(filteredSessions.count, 5) - 1 {
                                                Divider()
                                                    .background(Color.white.opacity(0.08))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                
                Spacer(minLength: 0)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        StatsTab()
    }
}
