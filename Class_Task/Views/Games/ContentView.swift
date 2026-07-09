//
//   ContentView.swift
//   Class_Task
//
//   Created by Sohan Weerasinghe on 2026-06-07.
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
    @State private var isDangerTarget: Bool = false
    @State private var targetPosition: CGPoint = .zero
    @State private var hasPositionedTarget: Bool = false
    
    @State private var clicksThisSecond: Int = 0
    @State private var hasTappedThisSecond: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var dangerResetTask: DispatchWorkItem?
    
    @State private var audioPlayer: AVAudioPlayer?
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0
    
    let colorPalette: [Color] = [.green, .yellow, .pink, .blue, .purple, .orange, .cyan]
    let gameTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "1A1B2F"), Color(hex: "121214")],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
            
            Image("BackgroundIMG")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
                .opacity(0.12)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.backward.circle.fill")
                            Text("Exit Game")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(20)
                        .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)
                    
                    Text("Tap Frenzy")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 4)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text("\(score)")
                                .font(.title).bold()
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 1, height: 35)
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME LEFT")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text("\(timeRemaining)s")
                                .font(.title).bold()
                                .foregroundColor(timeRemaining <= 3 ? .red : .purple)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    Spacer()
                }
            }
            
            GeometryReader { geometry in
                if !isGameOver {
                    targetButton(in: geometry.size)
                        .position(targetPosition)
                        .onAppear {
                            if !hasPositionedTarget {
                                moveTarget(in: geometry.size)
                            }
                        }
                        .onChange(of: geometry.size) {
                            moveTarget(in: geometry.size)
                        }
                }
            }
            
            if isGameOver {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 24) {
                    Text("GAME OVER 🕹️")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                    
                    VStack(spacing: 8) {
                        Text("Final Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if score > tapMeHighScore {
                            Text("🎉 New High Score! 🎉")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .bold()
                                .padding(.top, 4)
                        } else {
                            Text("Best Score: \(tapMeHighScore)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            resetGame()
                        }
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.gradient)
                            .cornerRadius(14)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(radius: 20)
                .padding(.horizontal, 36)
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .onReceive(gameTimer) { _ in
            withAnimation(.default) {
                updateGameTick()
            }
        }
    }
        
    private func targetButton(in size: CGSize) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                buttonScale = 0.9
            }
            handleTargetTap(in: size)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    buttonScale = 1.0
                }
            }
        }) {
            ZStack {
                if isDangerTarget {
                    Circle()
                        .fill(Color.red.opacity(0.95))
                        .frame(width: 160, height: 160)
                        .shadow(color: Color.red.opacity(0.6), radius: 25, x: 0, y: 10)
                    
                    Image("dangerTarget")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.75), lineWidth: 3)
                        )
                } else {
                    Circle()
                        .fill(currentColor.gradient)
                        .frame(width: 160, height: 160)
                        .shadow(color: currentColor.opacity(0.5), radius: 25, x: 0, y: 10)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 4)
                        .frame(width: 135, height: 135)
                    
                    Text("TAP!")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
            }
            .frame(width: 160, height: 160)
        }
        .scaleEffect(buttonScale)
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
    }
    
    // --- Core Methods Kept Securely Inside Struct Scope ---
    func handleTargetTap(in size: CGSize) {
        if isDangerTarget {
            endGame()
            return
        }
        
        clicksThisSecond = clicksThisSecond + 1
        hasTappedThisSecond = true
        randomizeTarget(in: size)
    }
    
    private func randomizeTarget(in size: CGSize) {
        dangerResetTask?.cancel()
        
        let randomIndex = Int.random(in: 0..<colorPalette.count)
        currentColor = colorPalette[randomIndex]
        isDangerTarget = randomIndex == 0
        moveTarget(in: size)
        
        if isDangerTarget {
            scheduleDangerTargetReset(in: size)
        }
    }
    
    private func scheduleDangerTargetReset(in size: CGSize) {
        let resetTask = DispatchWorkItem {
            guard !isGameOver, isDangerTarget else { return }
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isDangerTarget = false
                currentColor = colorPalette.randomElement() ?? .blue
                moveTarget(in: size)
            }
        }
        
        dangerResetTask = resetTask
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: resetTask)
    }
    
    private func moveTarget(in size: CGSize) {
        let radius: CGFloat = 80
        let topPadding: CGFloat = 210
        let bottomPadding: CGFloat = 120
        let minX = radius + 16
        let maxX = max(minX, size.width - radius - 16)
        let minY = min(size.height - radius, topPadding)
        let maxY = max(minY, size.height - bottomPadding)
        
        targetPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
        hasPositionedTarget = true
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
                endGame()
            }
        }
    }
    
    func resetGame() {
        dangerResetTask?.cancel()
        dangerResetTask = nil
        score = 0
        timeRemaining = 10
        currentColor = .blue
        isDangerTarget = false
        isGameOver = false
        clicksThisSecond = 0
        hasTappedThisSecond = false
        buttonScale = 1.0
        hasPositionedTarget = false
        audioPlayer?.stop()
    }
    
    private func endGame() {
        guard !isGameOver else { return }
        
        dangerResetTask?.cancel()
        dangerResetTask = nil
        isGameOver = true
        GameSessionStore.shared.addSession(
            gameName: "Tap Me!",
            score: score,
            location: LocationService.shared.currentLocation
        )
        if score > tapMeHighScore {
            tapMeHighScore = score
        }
        playGameOverSound()
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

//Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 7: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
