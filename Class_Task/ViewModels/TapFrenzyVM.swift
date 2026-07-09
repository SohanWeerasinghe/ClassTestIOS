import SwiftUI
import Combine
import AVFoundation

class TapFrenzyVM: ObservableObject {
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 10
    @Published var isGameOver: Bool = false
    @Published var currentColor: Color = .blue
    @Published var isDangerTarget: Bool = false
    @Published var targetPosition: CGPoint = .zero
    @Published var hasPositionedTarget: Bool = false
    @Published var buttonScale: CGFloat = 1.0
    @Published var highScore: Int = UserDefaults.standard.integer(forKey: "tapMeHighScore")
    @Published var isNewHighScore: Bool = false
    
    let colorPalette: [Color] = [.green, .yellow, .pink, .blue, .purple, .orange, .cyan]
    
    private var clicksThisSecond: Int = 0
    private var hasTappedThisSecond: Bool = false
    private var dangerResetTask: DispatchWorkItem?
    private var audioPlayer: AVAudioPlayer?
    
    func handleTargetTap(in size: CGSize) {
        if isDangerTarget {
            endGame()
            return
        }
        
        clicksThisSecond += 1
        hasTappedThisSecond = true
        randomizeTarget(in: size)
    }
    
    func randomizeTarget(in size: CGSize) {
        dangerResetTask?.cancel()
        
        let randomIndex = Int.random(in: 0..<colorPalette.count)
        currentColor = colorPalette[randomIndex]
        isDangerTarget = randomIndex == 0
        moveTarget(in: size)
        
        if isDangerTarget {
            scheduleDangerTargetReset(in: size)
        }
    }
    
    func moveTarget(in size: CGSize) {
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
        guard !isGameOver else { return }
        
        if hasTappedThisSecond {
            if clicksThisSecond == 1 {
                score += 1
            } else if clicksThisSecond == 2 {
                score += 2
            } else if clicksThisSecond == 3 {
                score += 3
            } else if clicksThisSecond > 3 {
                score += clicksThisSecond + 10
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
        isNewHighScore = false
        audioPlayer?.stop()
    }
    
    func pressButton() {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
            buttonScale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                self.buttonScale = 1.0
            }
        }
    }
    
    private func scheduleDangerTargetReset(in size: CGSize) {
        let resetTask = DispatchWorkItem {
            guard !self.isGameOver, self.isDangerTarget else { return }
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                self.isDangerTarget = false
                self.currentColor = self.colorPalette.randomElement() ?? .blue
                self.moveTarget(in: size)
            }
        }
        
        dangerResetTask = resetTask
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: resetTask)
    }
    
    private func endGame() {
        guard !isGameOver else { return }
        
        dangerResetTask?.cancel()
        dangerResetTask = nil
        isGameOver = true
        GameSessionStore.shared.addSession(
            gameName: GameMode.tapMe.title,
            score: score,
            location: LocationService.shared.currentLocation
        )
        
        if score > highScore {
            highScore = score
            isNewHighScore = true
            UserDefaults.standard.set(score, forKey: "tapMeHighScore")
        }
        
        playGameOverSound()
    }
    
    private func playGameOverSound() {
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
