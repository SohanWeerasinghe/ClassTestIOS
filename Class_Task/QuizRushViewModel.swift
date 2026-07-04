//
//  QuizRushViewModel.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 3/7/2026.
//

import SwiftUI
import Combine

enum QuizViewState {
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
    @Published var viewState: QuizViewState = .loading
    @Published var currentAnswers: [String] = []
    
    // Keeps track of the last answer's status for visual flashes/feedback
    @Published var feedbackColor: Color = .clear
    
    /// Asynchronously fetches 10 multiple-choice trivia items
    func fetchQuestions() async {
        await MainActor.run {
            self.viewState = .loading
            self.currentIndex = 0
            self.score = 0
            self.streak = 0
        }
        
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            await MainActor.run { self.viewState = .failed }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
            
            await MainActor.run {
                if !decodedResponse.results.isEmpty {
                    self.questions = decodedResponse.results
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
    
    /// Combines and shuffles correct and incorrect options once per question
    private func shuffleAnswersForCurrentQuestion() {
        guard currentIndex < questions.count else { return }
        let currentQuestion = questions[currentIndex]
        var choices = currentQuestion.incorrectAnswers
        choices.append(currentQuestion.correctAnswer)
        self.currentAnswers = choices.shuffled()
    }
    
    /// Valdiates user selections, adjusts game metrics, and pushes view states
    func submitAnswer(_ selectedAnswer: String) {
        guard currentIndex < questions.count else { return }
        
        let currentQuestion = questions[currentIndex]
        
        if selectedAnswer == currentQuestion.correctAnswer {
            streak += 1
            // Basic score points + cumulative streak multiplier bonuses
            score += 10 + (streak * 2)
            feedbackColor = .green.opacity(0.4)
        } else {
            streak = 0
            if score >= 5 { score -= 5 } // Apply a small penalty
            feedbackColor = .red.opacity(0.4)
        }
        
        // Brief delay so the user can visualize correct/wrong screen feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.feedbackColor = .clear
            self.currentIndex += 1
            
            if self.currentIndex < self.questions.count {
                self.shuffleAnswersForCurrentQuestion()
            } else {
                self.viewState = .gameOver
            }
        }
    }
}
