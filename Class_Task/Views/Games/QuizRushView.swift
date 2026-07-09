import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()
    @AppStorage("quizRushHighScore") private var highScore: Int = 0
    @AppStorage("quizCategory") private var selectedCategoryRawValue: Int = QuizCategory.any.rawValue
    @AppStorage("quizDifficulty") private var selectedDifficultyRawValue: String = QuizDifficulty.any.rawValue
    @AppStorage("quizRandomizeSettings") private var randomizeQuizSettings: Bool = false
    
    @State private var selectedAnswer: String? = nil
    @State private var hasSubmitted: Bool = false
    @State private var activeCategory: QuizCategory = .any
    @State private var activeDifficulty: QuizDifficulty = .any
    
    private var selectedCategory: QuizCategory {
        QuizCategory(rawValue: selectedCategoryRawValue) ?? .any
    }
    
    private var selectedDifficulty: QuizDifficulty {
        QuizDifficulty(rawValue: selectedDifficultyRawValue) ?? .any
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            viewModel.feedbackColor
                .ignoresSafeArea()
                .animation(.easeInOut, value: viewModel.feedbackColor)
            
            switch viewModel.viewState {
            case .setup:
                setupView
            case .loading:
                loadingView
            case .failed:
                failedView
            case .loaded:
                gameView
            case .gameOver:
                gameOverView
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var setupView: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 52))
                        .foregroundColor(.purple)
                    
                    Text("Quiz Rush")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Choose your round before the live trivia starts.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 30)
                
                VStack(spacing: 16) {
                    Toggle("Randomize each round", isOn: $randomizeQuizSettings)
                        .font(.headline)
                    
                    Picker("Category", selection: $selectedCategoryRawValue) {
                        ForEach(QuizCategory.allCases) { category in
                            Text(category.title).tag(category.rawValue)
                        }
                    }
                    .disabled(randomizeQuizSettings)
                    
                    Picker("Difficulty", selection: $selectedDifficultyRawValue) {
                        ForEach(QuizDifficulty.allCases) { difficulty in
                            Text(difficulty.title).tag(difficulty.rawValue)
                        }
                    }
                    .disabled(randomizeQuizSettings)
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Button(action: startRound) {
                    Text("Start Game")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Fetching Live Trivia...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var failedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Could not load questions for this setup.")
                .font(.title3).bold()
                .multilineTextAlignment(.center)
            Text("Try another category or difficulty if OpenTDB has no matching questions.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: startRound) {
                Text("Retry")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 140)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button("Change Setup") {
                viewModel.viewState = .setup
            }
            .font(.subheadline)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 20) {
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
                    Text("\(viewModel.streak)")
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
            
            Text("\(activeCategory.title) - \(activeDifficulty.title)")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.horizontal)
            
            Spacer()
            
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
    }
    
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Text("Round Completed!")
                .font(.largeTitle).bold()
            
            VStack(spacing: 8) {
                Text("Your Final Score: \(viewModel.score)")
                    .font(.title3)
                
                if viewModel.score > highScore {
                    Text("New Mode High Score!")
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
                startRound()
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
            
            Button("Change Setup") {
                if viewModel.score > highScore {
                    highScore = viewModel.score
                }
                viewModel.viewState = .setup
            }
            .font(.subheadline)
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
    
    private func startRound() {
        activeCategory = randomizeQuizSettings ? .randomPlayable : selectedCategory
        activeDifficulty = randomizeQuizSettings ? .randomPlayable : selectedDifficulty
        selectedAnswer = nil
        hasSubmitted = false
        
        Task {
            await viewModel.fetchQuestions(category: activeCategory, difficulty: activeDifficulty)
        }
    }
    
    private func buttonBackgroundColor(isCorrect: Bool, isSelected: Bool) -> Color {
        guard hasSubmitted else { return Color(uiColor: .secondarySystemGroupedBackground) }
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isSelected {
            return Color.red.opacity(0.2)
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
