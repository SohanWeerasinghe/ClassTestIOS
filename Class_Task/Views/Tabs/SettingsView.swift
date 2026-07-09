import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("quizCategory") private var quizCategoryRawValue: Int = QuizCategory.any.rawValue
    @AppStorage("quizDifficulty") private var quizDifficultyRawValue: String = QuizDifficulty.any.rawValue
    @AppStorage("quizRandomizeSettings") private var randomizeQuizSettings: Bool = false
    
    @AppStorage("dailyNotificationsEnabled") private var dailyNotificationsEnabled: Bool = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour: Int = 9
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute: Int = 0
    @AppStorage("dailyChallengeCategory") private var dailyChallengeCategoryRawValue: Int = QuizCategory.any.rawValue
    @AppStorage("dailyChallengeDifficulty") private var dailyChallengeDifficultyRawValue: String = QuizDifficulty.any.rawValue
    
    @AppStorage("tapMeHighScore") private var tapMeHighScore: Int = 0
    @AppStorage("lightUpHighScore") private var lightUpHighScore: Int = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore: Int = 0
    
    @State private var notificationTime = Date()
    @State private var showResetConfirmation = false
    @State private var notificationStatus = "Daily challenge notifications are off."
    
    private let notificationIdentifier = "dailyChallengeReminder"
    
    private var dailyChallengeCategory: QuizCategory {
        QuizCategory(rawValue: dailyChallengeCategoryRawValue) ?? .any
    }
    
    private var dailyChallengeDifficulty: QuizDifficulty {
        QuizDifficulty(rawValue: dailyChallengeDifficultyRawValue) ?? .any
    }
    
    var body: some View {
        ZStack {
            Image("back2")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.6)
            
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        Text("Settings")
                            .font(.system(size: 50, weight: .black))
                            .foregroundColor(.black)
                            .fontDesign(.serif)
                        
                        Text("Quiz setup and daily challenge reminders")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 30)
                    
                    settingsSection(title: "Quiz Rush Defaults", icon: "brain.head.profile", color: .purple) {
                        Toggle("Randomize each round", isOn: $randomizeQuizSettings)
                        
                        Picker("Category", selection: $quizCategoryRawValue) {
                            ForEach(QuizCategory.allCases) { category in
                                Text(category.title).tag(category.rawValue)
                            }
                        }
                        .disabled(randomizeQuizSettings)
                        
                        Picker("Difficulty", selection: $quizDifficultyRawValue) {
                            ForEach(QuizDifficulty.allCases) { difficulty in
                                Text(difficulty.title).tag(difficulty.rawValue)
                            }
                        }
                        .disabled(randomizeQuizSettings)
                    }
                    
                    settingsSection(title: "Daily Challenge", icon: "bell.fill", color: .orange) {
                        Toggle("Daily notification", isOn: $dailyNotificationsEnabled)
                        
                        DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .disabled(!dailyNotificationsEnabled)
                        
                        Picker("Target category", selection: $dailyChallengeCategoryRawValue) {
                            ForEach(QuizCategory.allCases) { category in
                                Text(category.title).tag(category.rawValue)
                            }
                        }
                        .disabled(!dailyNotificationsEnabled)
                        
                        Picker("Target difficulty", selection: $dailyChallengeDifficultyRawValue) {
                            ForEach(QuizDifficulty.allCases) { difficulty in
                                Text(difficulty.title).tag(difficulty.rawValue)
                            }
                        }
                        .disabled(!dailyNotificationsEnabled)
                        
                        Text(notificationStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    settingsSection(title: "Stats", icon: "trash.fill", color: .red) {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            HStack {
                                Text("Reset all stats")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .pickerStyle(.menu)
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
    
    private func settingsSection<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(color)
                    .cornerRadius(10)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                content()
            }
            .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
                await MainActor.run {
                    notificationStatus = "Daily challenge notifications are off."
                }
            }
        }
    }
    
    private func scheduleDailyNotification() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let allowed = try await center.requestAuthorization(options: [.alert, .sound])
            guard allowed else {
                await MainActor.run {
                    dailyNotificationsEnabled = false
                    notificationStatus = "Notifications are blocked in iPhone Settings."
                }
                return
            }
            
            center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
            
            let content = UNMutableNotificationContent()
            content.title = "Daily Challenge"
            content.body = "Play \(dailyChallengeCategory.title) on \(dailyChallengeDifficulty.title)."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.hour = dailyChallengeHour
            dateComponents.minute = dailyChallengeMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
            try await center.add(request)
            
            await MainActor.run {
                notificationStatus = "Daily challenge scheduled at \(formattedNotificationTime())."
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
        SettingsView()
    }
}
