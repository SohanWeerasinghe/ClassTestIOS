import SwiftUI

struct ScoreBadge: View {
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
    ScoreBadge(
        gameTitle: "Quiz Rush",
        highScore: 240,
        icon: "brain.head.profile",
        themeColor: .purple
    )
    .padding()
    .background(Color.gray.opacity(0.15))
}
