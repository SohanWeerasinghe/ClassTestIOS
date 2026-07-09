import SwiftUI
import Charts

struct LeaderboardView: View {
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
    
    var body: some View {
        ZStack {
            Image("back2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Stats")
                        .font(.system(size: 50, weight: .black))
                        .foregroundColor(.black)
                        .fontDesign(.serif)
                    
                    Text("Your arcade analytics")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.top, 30)
                
                Picker("Select Game", selection: $statsVM.selectedFilter) {
                    ForEach(GameModeFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 25)
                
                ScrollView {
                    VStack(spacing: 22) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL GAMES")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.gray)
                                Text("\(filteredSessions.count)")
                                    .font(.title).bold()
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOP SCORE")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.gray)
                                Text("\(maximumScore)")
                                    .font(.title).bold()
                                    .foregroundColor(.purple)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        
                        if !filteredSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Score Progress History")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Chart {
                                    ForEach(Array(filteredSessions.enumerated()), id: \.offset) { index, session in
                                        BarMark(
                                            x: .value("Game #", "G\(index + 1)"),
                                            y: .value("Score", session.score)
                                        )
                                        .foregroundStyle(statsVM.colorForGame(session.gameName))
                                        .cornerRadius(4)
                                    }
                                }
                                .frame(height: 180)
                                .padding(.top, 10)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                        
                        VStack(spacing: 12) {
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .tapMe {
                                LeaderboardCard(
                                    gameTitle: GameMode.tapMe.title,
                                    highScore: tapMeHighScore,
                                    icon: GameMode.tapMe.icon,
                                    themeColor: GameMode.tapMe.color
                                )
                            }
                            
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .lightItUp {
                                LeaderboardCard(
                                    gameTitle: GameMode.lightItUp.title,
                                    highScore: lightUpHighScore,
                                    icon: GameMode.lightItUp.icon,
                                    themeColor: GameMode.lightItUp.color
                                )
                            }
                            
                            if statsVM.selectedFilter == .all || statsVM.selectedFilter == .quizRush {
                                LeaderboardCard(
                                    gameTitle: GameMode.quizRush.title,
                                    highScore: quizRushHighScore,
                                    icon: GameMode.quizRush.icon,
                                    themeColor: GameMode.quizRush.color
                                )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Game Log")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if filteredSessions.isEmpty {
                                Text("No matches played yet under this filter.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 10)
                            } else {
                                ForEach(filteredSessions.reversed().prefix(5)) { session in
                                    HStack {
                                        Circle()
                                            .fill(statsVM.colorForGame(session.gameName))
                                            .frame(width: 10, height: 10)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.gameName)
                                                .font(.subheadline).bold()
                                                .foregroundColor(.black)
                                            Text(session.date.formatted(date: .numeric, time: .shortened))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(String(session.score) + " pts")
                                            .font(.system(.subheadline, design: .rounded)).bold()
                                            .foregroundColor(.black)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 5)
                }
                
                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LeaderboardCard: View {
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
    NavigationStack {
        LeaderboardView()
    }
}
