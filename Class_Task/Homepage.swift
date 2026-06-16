//
//  Homepage.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 15/6/2026.
//

import SwiftUI
import AVFoundation

struct Homepage: View {
    @State private var backgroundMusicPlayer: AVAudioPlayer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("back2")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.6)
                
                VStack(spacing: 35) {
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.black)
                            .fontDesign(.serif)
                        Text("Game Arcade")
                            .font(.system(size: 50, weight: .black))
                            .foregroundColor(.black)
                            .fontDesign(.serif)
                        
                        Text("Select a game to play")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: LoadingScreen()) {
                            GameMenuCard(title: "Tap Me!",
                                         subtitle: "Test your speed clicking skills",
                                         icon: "hand.tap.fill",
                                         color: .orange) // Fixed: changed Color.orange to color: .orange
                        }
                        
                        NavigationLink(destination: LightUpLoadingScreen()) {
                            GameMenuCard(title: "Light It Up",
                                         subtitle: "Your brilliant next project",
                                         icon: "inset.filled.square",
                                         color: .green)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: LeaderboardView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                Text("Scores")
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.orange)
                        }
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
    }
    
    
    private func playBackgroundMusic() {
        if let path = Bundle.main.path(forResource: "gamingmusic", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loops indefinitely
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

struct GameMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 35))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(color)
                .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    Homepage()
}
