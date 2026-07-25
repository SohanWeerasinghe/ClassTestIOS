//
//  TapFrenzyView.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 13/6/2026.
//

import SwiftUI
import Combine

struct TapFrenzyView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TapFrenzyVM()
    
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
                            Text("\(viewModel.score)")
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
                            Text("\(viewModel.timeRemaining)s")
                                .font(.title).bold()
                                .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .purple)
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
                if !viewModel.isGameOver {
                    targetButton(in: geometry.size)
                        .position(viewModel.targetPosition)
                        .onAppear {
                            if !viewModel.hasPositionedTarget {
                                viewModel.moveTarget(in: geometry.size)
                            }
                        }
                        .onChange(of: geometry.size) {
                            viewModel.moveTarget(in: geometry.size)
                        }
                }
            }
            
            if viewModel.isGameOver {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                ResultView(
                    title: "Game Over",
                    gameName: "Tap Frenzy",
                    score: viewModel.score,
                    bestScore: viewModel.highScore,
                    isNewHighScore: viewModel.isNewHighScore,
                    themeColor: .blue
                ) {
                    withAnimation(.spring()) {
                        viewModel.resetGame()
                    }
                }
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .onReceive(gameTimer) { _ in
            withAnimation(.default) {
                viewModel.updateGameTick()
            }
        }
    }
    
    private func targetButton(in size: CGSize) -> some View {
        Button(action: {
            viewModel.pressButton()
            viewModel.handleTargetTap(in: size)
        }) {
            ZStack {
                if viewModel.isDangerTarget {
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
                        .fill(viewModel.currentColor.gradient)
                        .frame(width: 160, height: 160)
                        .shadow(color: viewModel.currentColor.opacity(0.5), radius: 25, x: 0, y: 10)
                    
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
        .scaleEffect(viewModel.buttonScale)
        .buttonStyle(PlainButtonStyle())
        .transition(.scale.combined(with: .opacity))
    }
}

extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

#Preview {
    TapFrenzyView()
}
