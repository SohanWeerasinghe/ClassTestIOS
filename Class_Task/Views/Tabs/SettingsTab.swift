//
//  SettingsTab.swift
//  Class_Task
//
//  Created by Sohan Weerasinghe on 10/7/2026.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("quizCategory") private var quizCategoryRawValue: Int = QuizCategory.any.rawValue
    @AppStorage("quizDifficulty") private var quizDifficultyRawValue: String = QuizDifficulty.any.rawValue
    @AppStorage("quizRandomizeSettings") private var randomizeQuizSettings: Bool = false
    
    @AppStorage("dailyNotificationsEnabled") private var dailyNotificationsEnabled: Bool = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour: Int = 9
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute: Int = 0
    @AppStorage("dailyChallengeCategory") private var dailyChallengeCategoryRawValue: Int = QuizCategory.any.rawValue
    @AppStorage("dailyChallengeDifficulty") private var dailyChallengeDifficultyRawValue: String = QuizDifficulty.any.rawValue
    
    @AppStorage("tapFrenzyDuration") private var tapFrenzyDuration: Int = 10
    @AppStorage("lightItUpDuration") private var lightItUpDuration: Int = 60
    @AppStorage("quizRushQuestionCount") private var quizRushQuestionCount: Int = 10
    
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0
    @AppStorage("lightUpHighScore") private var lightUpHighScore: Int = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore: Int = 0
    
    @State private var notificationTime = Date()
    @State private var showResetConfirmation = false
    @State private var notificationStatus = "Daily challenge notifications are off."
    
    private var dailyChallengeCategory: QuizCategory {
        QuizCategory(rawValue: dailyChallengeCategoryRawValue) ?? .any
    }
    
    private var dailyChallengeDifficulty: QuizDifficulty {
        QuizDifficulty(rawValue: dailyChallengeDifficultyRawValue) ?? .any
    }
    
    // Background Color Palette
    private let darkBackground = Color(red: 13/255, green: 15/255, blue: 23/255)
    
    var body: some View {
        ZStack {
            // Dark Background
            darkBackground
                .ignoresSafeArea()
            
            // Neon Glow Effects
            RadialGradient(
                colors: [Color.purple.opacity(0.18), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.cyan.opacity(0.15), Color.clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Title Header
                    VStack(spacing: 6) {
                        Text("CONTROL CENTER")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .tracking(3)
                        
                        Text("Settings")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 0)
                        
                        Text("Quiz setup, game sessions and reminders")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(.top, 20)
                    
                    // Quiz Settings Card
                    settingsSection(title: "Quiz Rush Defaults", icon: "brain.head.profile", color: .purple) {
                        Toggle("Randomize each round", isOn: $randomizeQuizSettings)
                            .tint(.purple)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Picker("Category", selection: $quizCategoryRawValue) {
                            ForEach(QuizCategory.allCases) { category in
                                Text(category.title).tag(category.rawValue)
                            }
                        }
                        .disabled(randomizeQuizSettings)
                        .opacity(randomizeQuizSettings ? 0.5 : 1.0)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Picker("Difficulty", selection: $quizDifficultyRawValue) {
                            ForEach(QuizDifficulty.allCases) { difficulty in
                                Text(difficulty.title).tag(difficulty.rawValue)
                            }
                        }
                        .disabled(randomizeQuizSettings)
                        .opacity(randomizeQuizSettings ? 0.5 : 1.0)
                    }
                    
                    // Game Timers Card
                    settingsSection(title: "Game Sessions", icon: "timer", color: .cyan) {
                        Stepper("Tap Frenzy: \(tapFrenzyDuration) seconds", value: $tapFrenzyDuration, in: 5...60, step: 5)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Stepper("Light It Up: \(lightItUpDuration) seconds", value: $lightItUpDuration, in: 30...180, step: 15)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Stepper("Quiz Rush: \(quizRushQuestionCount) questions", value: $quizRushQuestionCount, in: 5...20, step: 5)
                    }
                    
                    // Notifications Card
                    settingsSection(title: "Daily Challenge", icon: "bell.fill", color: .orange) {
                        Toggle(isOn: $dailyNotificationsEnabled) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Notifications")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(dailyNotificationsEnabled ? "Daily challenge reminders are on" : "Daily challenge reminders are off")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.55))
                            }
                        }
                        .tint(.orange)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .disabled(!dailyNotificationsEnabled)
                            .opacity(dailyNotificationsEnabled ? 1.0 : 0.5)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Picker("Target category", selection: $dailyChallengeCategoryRawValue) {
                            ForEach(QuizCategory.allCases) { category in
                                Text(category.title).tag(category.rawValue)
                            }
                        }
                        .disabled(!dailyNotificationsEnabled)
                        .opacity(dailyNotificationsEnabled ? 1.0 : 0.5)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Picker("Target difficulty", selection: $dailyChallengeDifficultyRawValue) {
                            ForEach(QuizDifficulty.allCases) { difficulty in
                                Text(difficulty.title).tag(difficulty.rawValue)
                            }
                        }
                        .disabled(!dailyNotificationsEnabled)
                        .opacity(dailyNotificationsEnabled ? 1.0 : 0.5)
                        
                        Text(notificationStatus)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(dailyNotificationsEnabled ? .orange : Color.white.opacity(0.4))
                            .padding(.top, 4)
                    }
                    
                    // Reset Data Card
                    settingsSection(title: "Stats & Storage", icon: "trash.fill", color: .red) {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            HStack {
                                Text("Reset all stats")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.pink)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.pink.opacity(0.6))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .pickerStyle(.menu)
        .preferredColorScheme(.dark)
        .onAppear {
            notificationTime = storedNotificationTime()
            updateNotificationStatus()
        }
        .onChange(of: dailyNotificationsEnabled) {
            updateDailyNotification()
        }
        .onChange(of: notificationTime) {
            storeNotificationTime()
            updateDailyNotification()
        }
        .onChange(of: dailyChallengeCategoryRawValue) {
            updateDailyNotification()
        }
        .onChange(of: dailyChallengeDifficultyRawValue) {
            updateDailyNotification()
        }
        .confirmationDialog("Reset all stats?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset", role: .destructive) {
                resetAllStats()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This clears high scores and saved game history.")
        }
    }
    
    // Reusable Box Layout Function
    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color.opacity(0.6), lineWidth: 1.5)
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                .frame(width: 38, height: 38)
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 0)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Inner Content
            VStack(spacing: 12) {
                content()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
    
    private func storedNotificationTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = dailyChallengeHour
        components.minute = dailyChallengeMinute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func storeNotificationTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        dailyChallengeHour = components.hour ?? 9
        dailyChallengeMinute = components.minute ?? 0
    }
    
    private func updateDailyNotification() {
        Task {
            if dailyNotificationsEnabled {
                await scheduleDailyNotification()
            } else {
                NotificationService.cancelDailyChallenge()
                await MainActor.run {
                    notificationStatus = "Daily challenge notifications are off."
                }
            }
        }
    }
    
    private func scheduleDailyNotification() async {
        do {
            let allowed = try await NotificationService.scheduleDailyChallenge(
                hour: dailyChallengeHour,
                minute: dailyChallengeMinute,
                category: dailyChallengeCategory,
                difficulty: dailyChallengeDifficulty
            )
            
            await MainActor.run {
                if allowed {
                    notificationStatus = "Daily challenge scheduled at \(formattedNotificationTime())."
                } else {
                    dailyNotificationsEnabled = false
                    notificationStatus = "Notifications are blocked in iPhone Settings."
                }
            }
        } catch {
            await MainActor.run {
                notificationStatus = "Could not schedule notification."
            }
        }
    }
    
    private func updateNotificationStatus() {
        notificationStatus = dailyNotificationsEnabled
            ? "Daily challenge scheduled at \(formattedNotificationTime())."
            : "Daily challenge notifications are off."
    }
    
    private func formattedNotificationTime() -> String {
        notificationTime.formatted(date: .omitted, time: .shortened)
    }
    
    private func resetAllStats() {
        tapMeHighScore = 0
        lightUpHighScore = 0
        quizRushHighScore = 0
        GameSessionStore.shared.clearSessions()
    }
}

#Preview {
    NavigationStack {
        SettingsTab()
    }
}
