//
//  ContentView.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 2026-06-07.
//

import SwiftUI
import Combine
import CoreHaptics
import AVFoundation

struct ContentView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var isGameOver: Bool = false
    @State private var currentColor: Color = .blue
    
    @State private var clicksThisSecond: Int = 0
    @State private var hasTappedThisSecond: Bool = false
    
    @State private var audioPlayer: AVAudioPlayer?
    
    let colorPalette: [Color] = [.red, .green, .yellow, .pink, .blue, .purple, .orange, .cyan]
    let gameTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            
            Color.white.ignoresSafeArea()
            
            Image("BackgroundIMG")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "door.left.hand.open")
                            Text("Exit Game")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                VStack(spacing: 20) {
                    
                    Spacer().frame(height: 10)
                    
                    if isGameOver {
                        Text("GAME OVER 🕹️")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.red)
                    } else {
                        Text("Tap Me!")
                            .font(.system(size: 60, weight: .black))
                            .foregroundColor(.black)
                        
                        Text("Time Left: \(timeRemaining)s")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    
                    Text("Score: \(score)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    if isGameOver {
                        Button(action: {
                            resetGame()
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 180)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    } else {
                        Button(action: {
                            handleTargetTap()
                        }) {
                            Image(<#T##resource: ImageResource##ImageResource#>, )
                                .foregroundColor(currentColor)
                                .frame(width: 140, height: 140)
                                .shadow(radius: 10)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onReceive(gameTimer) { _ in
            updateGameTick()
        }
    }
    
    func handleTargetTap() {
        if let randomColor = colorPalette.randomElement() {
            currentColor = randomColor
        }
        clicksThisSecond = clicksThisSecond + 1
        hasTappedThisSecond = true
    }
    
    func updateGameTick() {
        if isGameOver == false {
            if hasTappedThisSecond == true {
                if clicksThisSecond == 1 {
                    score = score + 1
                } else if clicksThisSecond == 2 {
                    score = score + 2
                } else if clicksThisSecond == 3 {
                    score = score + 3
                } else if clicksThisSecond > 3 {
                    score = score + clicksThisSecond + 10
                }
                clicksThisSecond = 0
                hasTappedThisSecond = false
            }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isGameOver = true
                playGameOverSound()
            }
        }
    }
    
    func resetGame() {
        score = 0
        timeRemaining = 10
        currentColor = .blue
        isGameOver = false
        clicksThisSecond = 0
        hasTappedThisSecond = false
        audioPlayer?.stop()
    }
    
    func playGameOverSound() {
        if let path = Bundle.main.path(forResource: "Game Over", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound file structure")
            }
        }
    }
}

#Preview {
    ContentView()
}
