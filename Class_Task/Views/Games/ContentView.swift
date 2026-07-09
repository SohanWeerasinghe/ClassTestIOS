import SwiftUI
import Combine

struct ContentView: View {
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
                
                VStack(spacing: 24) {
                    Text("GAME OVER 🕹️")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                    
                    VStack(spacing: 8) {
                        Text("Final Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.score)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                        
                        if viewModel.isNewHighScore {
                            Text("🎉 New High Score! 🎉")
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .bold()
                                .padding(.top, 4)
                        } else {
                            Text("Best Score: \(viewModel.highScore)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.resetGame()
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
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 7:
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
