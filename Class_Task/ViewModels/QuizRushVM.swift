//
//  QuizRushViewModel.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 3/7/2026.
//

import SwiftUI
import Combine

enum QuizViewState {
    case setup
    case loading
    case failed
    case loaded
    case gameOver
}

class QuizRushViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var viewState: QuizViewState = .setup
    @Published var currentAnswers: [String] = []
    
    @Published var feedbackColor: Color = .clear
    
    func fetchQuestions(category: QuizCategory, difficulty: QuizDifficulty) async {
        await MainActor.run {
            self.viewState = .loading
            self.currentIndex = 0
            self.score = 0
            self.streak = 0
            self.questions = []
            self.currentAnswers = []
        }
        
        do {
            let loadedQuestions = try await TriviaAPI.fetchQuestions(category: category, difficulty: difficulty)
            
            await MainActor.run {
                if !loadedQuestions.isEmpty {
                    self.questions = loadedQuestions
                    self.viewState = .loaded
                    self.shuffleAnswersForCurrentQuestion()
                } else {
                    self.viewState = .failed
                }
            }
        } catch {
            print("Network/Parsing Error: \(error.localizedDescription)")
            await MainActor.run {
                self.viewState = .failed
            }
        }
    }
    
    private func shuffleAnswersForCurrentQuestion() {
        guard currentIndex < questions.count else { return }
        let currentQuestion = questions[currentIndex]
        var choices = currentQuestion.incorrectAnswers
        choices.append(currentQuestion.correctAnswer)
        self.currentAnswers = choices.shuffled()
    }
    
    func submitAnswer(_ selectedAnswer: String) {
        guard currentIndex < questions.count else { return }
        
        let currentQuestion = questions[currentIndex]
        
        if selectedAnswer == currentQuestion.correctAnswer {
            streak += 1
            score += 10 + (streak * 2)
            feedbackColor = .green.opacity(0.4)
        } else {
            streak = 0
            if score >= 5 { score -= 5 } // Apply a small penalty
            feedbackColor = .red.opacity(0.4)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.feedbackColor = .clear
            self.currentIndex += 1
            
            if self.currentIndex < self.questions.count {
                self.shuffleAnswersForCurrentQuestion()
            } else {
                GameSessionStore.shared.addSession(
                    gameName: "Quiz Rush",
                    score: self.score,
                    location: LocationService.shared.currentLocation
                )
                self.viewState = .gameOver
            }
        }
    }
}
