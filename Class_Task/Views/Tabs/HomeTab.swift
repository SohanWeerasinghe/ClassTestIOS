//
//  HomeTab.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 13/6/2026.
//

import SwiftUI
import AVFoundation

struct HomeTab: View {
    @State private var backgroundMusicPlayer: AVAudioPlayer?
    
    // for the background theme Palette
    private let bgDark = Color(red: 13/255, green: 15/255, blue: 23/255)
    
    var body: some View {
        TabView {
            NavigationStack {
                ZStack {
                    // dark color theme for the background
                    bgDark.ignoresSafeArea()
                    
                    // background glow effect
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.18), Color.clear],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 350
                    )
                    .ignoresSafeArea()
                    
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.16, blue: 0.52).opacity(0.15), Color.clear],
                        center: .bottomTrailing,
                        startRadius: 20,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            
                            // Home page header titlr
                            VStack(spacing: 6) {
                                HStack(spacing: 6) {
                                    Text("WELCOME TO")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(Color.cyan)
                                        .tracking(3)
                                }
                                
                                Text("GAME ARCADE")
                                    .font(.system(size: 38, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)
                                
                                Text("Select a arena to start playing")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.6))
                            }
                            .padding(.top, 25)
                            
                            // 3 main game cards list
                            VStack(spacing: 16) {
                                NavigationLink(destination: LoadingScreen()) {
                                    GameMenuCard(
                                        title: "Tap Frenzy!",
                                        subtitle: "Test your speed clicking skills",
                                        icon: "hand.tap.fill",
                                        accentColor: Color.orange
                                    )
                                }
                                
                                NavigationLink(destination: LightItUpView()) {
                                    GameMenuCard(
                                        title: "Light It Up",
                                        subtitle: "Click the lighted square fast!",
                                        icon: "inset.filled.square",
                                        accentColor: Color.green
                                    )
                                }
                                
                                NavigationLink(destination: QuizRushView()) {
                                    GameMenuCard(
                                        title: "Quiz Rush",
                                        subtitle: "Challenge your mind with trivia!",
                                        icon: "brain.head.profile",
                                        accentColor: Color.purple
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer(minLength: 30)
                        }
                    }
                }
                .onAppear {
                    playBackgroundMusic()
                }
                .onDisappear {
                    stopBackgroundMusic()
                }
            }
            .tabItem {
                Image(systemName: "gamecontroller.fill")
                Text("Home")
            }
            
            NavigationStack {
                StatsTab()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }
            
            NavigationStack {
                MapTab()
            }
            .tabItem {
                Image(systemName: "map.fill")
                Text("Map")
            }
            
            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .tint(Color.cyan)
        .preferredColorScheme(.dark)
    }
    
    private func playBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "gamingmusic", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.5
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Could not initialize background audio engine: \(error.localizedDescription)")
            }
        } else {
            print("Arcade background music file not found in main project bundle.")
        }
    }
    
    private func stopBackgroundMusic() {
        if backgroundMusicPlayer?.isPlaying == true {
            backgroundMusicPlayer?.stop()
            backgroundMusicPlayer = nil
        }
    }
}

struct SimpleTabPage: View {
    let title: String
    let icon: String
    
    private let bgDark = Color(red: 13/255, green: 15/255, blue: 23/255)
    
    var body: some View {
        ZStack {
            bgDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(.cyan)
                }
                
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

struct GameMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // game card icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(accentColor.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accentColor.opacity(0.6), lineWidth: 1.5)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(accentColor)
            }
            .frame(width: 60, height: 60)
            .shadow(color: accentColor.opacity(0.3), radius: 6, x: 0, y: 0)
            
            // Game menu card title code
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow icon for the every game access buttons
            Image(systemName: "chevron.right")
                .foregroundColor(Color.white.opacity(0.4))
                .font(.system(size: 14, weight: .bold))
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
}

#Preview {
    HomeTab()
}
