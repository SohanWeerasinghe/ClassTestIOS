import SwiftUI

struct ResultView: View {
    let title: String
    let score: Int
    let bestScore: Int
    let isNewHighScore: Bool
    let themeColor: Color
    let primaryActionTitle: String
    let primaryAction: () -> Void
    let secondaryActionTitle: String?
    let secondaryAction: (() -> Void)?

    init(
        title: String,
        score: Int,
        bestScore: Int,
        isNewHighScore: Bool,
        themeColor: Color = .blue,
        primaryActionTitle: String = "Play Again",
        primaryAction: @escaping () -> Void,
        secondaryActionTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.score = score
        self.bestScore = bestScore
        self.isNewHighScore = isNewHighScore
        self.themeColor = themeColor
        self.primaryActionTitle = primaryActionTitle
        self.primaryAction = primaryAction
        self.secondaryActionTitle = secondaryActionTitle
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(themeColor)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                if isNewHighScore {
                    Text("New High Score!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .bold()
                        .padding(.top, 4)
                } else {
                    Text("Best Score: \(bestScore)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)

            Button(action: primaryAction) {
                Text(primaryActionTitle)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeColor.gradient)
                    .cornerRadius(14)
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            if let secondaryActionTitle, let secondaryAction {
                Button(secondaryActionTitle, action: secondaryAction)
                    .font(.subheadline)
            }
        }
        .padding(30)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding(.horizontal, 36)
    }
}

#Preview {
    ResultView(
        title: "Game Over",
        score: 120,
        bestScore: 140,
        isNewHighScore: false,
        themeColor: .purple,
        primaryAction: { }
    )
}
