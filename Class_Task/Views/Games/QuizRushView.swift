import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @AppStorage("quizRushHighScore") private var highScore: Int = 0
    
    // Track selection states for highlighting
    @State private var selectedAnswer: String? = nil
    @State private var hasSubmitted: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            viewModel.feedbackColor
                .ignoresSafeArea()
                .animation(.easeInOut, value: viewModel.feedbackColor)
            
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Fetching Live Trivia...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
            case .failed:
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Network connection failed.")
                        .font(.title3).bold()
                    Button(action: {
                        Task { await viewModel.fetchQuestions() }
                    }) {
                        Text("Retry")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 140)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
            case .loaded:
                VStack(spacing: 20) {
                    // Top Stat HUD Panel Tracker Row
                    HStack {
                        VStack(alignment: .leading) {
                            Text("SCORE")
                                .font(.caption).foregroundColor(.secondary)
                            Text("\(viewModel.score)")
                                .font(.title2).bold()
                        }
                        Spacer()
                        VStack(alignment: .center) {
                            Text("STREAK")
                                .font(.caption).foregroundColor(.secondary)
                            Text("🔥 \(viewModel.streak)")
                                .font(.title2).bold()
                                .foregroundColor(viewModel.streak > 0 ? .orange : .secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("QUESTION")
                                .font(.caption).foregroundColor(.secondary)
                            Text("\(viewModel.currentIndex + 1) of 10")
                                .font(.title2).bold()
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(14)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Question Card View Frame Box
                    VStack {
                        Text(viewModel.questions[viewModel.currentIndex].question.decodedHTML)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity, minHeight: 160)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.04), radius: 5)
                    
                    Spacer()
                    
                    // Shuffled Quiz Answer Option Buttons with Conditional Highlighting
                    VStack(spacing: 12) {
                        ForEach(viewModel.currentAnswers, id: \.self) { answer in
                            let isCorrectAnswer = (answer == viewModel.questions[viewModel.currentIndex].correctAnswer)
                            let isThisButtonSelected = (answer == selectedAnswer)
                            
                            Button(action: {
                                guard !hasSubmitted else { return }
                                selectedAnswer = answer
                                hasSubmitted = true
                                viewModel.submitAnswer(answer)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    selectedAnswer = nil
                                    hasSubmitted = false
                                }
                            }) {
                                Text(answer.decodedHTML)
                                    .font(.body)
                                    .bold()
                                    .foregroundColor(buttonTextColor(isCorrect: isCorrectAnswer, isSelected: isThisButtonSelected))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(buttonBackgroundColor(isCorrect: isCorrectAnswer, isSelected: isThisButtonSelected))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(buttonBorderColor(isCorrect: isCorrectAnswer, isSelected: isThisButtonSelected), lineWidth: 2)
                                    )
                            }
                            .disabled(hasSubmitted)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
            case .gameOver:
                VStack(spacing: 24) {
                    Text("Round Completed! 🏁")
                        .font(.largeTitle).bold()
                    
                    VStack(spacing: 8) {
                        Text("Your Final Score: \(viewModel.score)")
                            .font(.title3)
                        
                        if viewModel.score > highScore {
                            Text("🎉 New Mode High Score! 🎉")
                                .foregroundColor(.green)
                                .bold()
                        }
                        
                        Text("Best Stored Score: \(max(viewModel.score, highScore))")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Button(action: {
                        if viewModel.score > highScore {
                            highScore = viewModel.score
                        }
                        Task { await viewModel.fetchQuestions() }
                    }) {
                        Text("Play Again")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(20)
                .padding()
                .shadow(radius: 8)
                .onAppear {
                    if viewModel.score > highScore {
                        highScore = viewModel.score
                    }
                }
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchQuestions()
        }
    }
        
    private func buttonBackgroundColor(isCorrect: Bool, isSelected: Bool) -> Color {
        guard hasSubmitted else { return Color(uiColor: .secondarySystemGroupedBackground) }
        if isCorrect {
            return Color.green.opacity(0.2) // Always turn the correct answer green
        } else if isSelected {
            return Color.red.opacity(0.2) // Turn the wrong chosen option red
        }
        return Color(uiColor: .secondarySystemGroupedBackground)
    }
    
    private func buttonTextColor(isCorrect: Bool, isSelected: Bool) -> Color {
        guard hasSubmitted else { return .primary }
        if isCorrect { return .green }
        if isSelected { return .red }
        return .secondary
    }
    
    private func buttonBorderColor(isCorrect: Bool, isSelected: Bool) -> Color {
        guard hasSubmitted else { return Color.gray.opacity(0.2) }
        if isCorrect { return .green }
        if isSelected { return .red }
        return Color.gray.opacity(0.1)
    }
}
