# 🕹️ Game Arcade (iOS Application)

---

## 🚀 App Modes & Features

### 1. ⚡ Tap Frenzy (Tap Me!)
* **Objective:** Click the dynamic button as many times as possible within a high-pressure 10-second window.
* **Mechanics:** Includes a cumulative combo scaling score engine. Multiple taps within the same second trigger dynamic score multipliers (`1x`, `2x`, `3x`, and higher multipliers with additional point injections). Features a dynamic color-shifting layout background with complete high score preservation.

### 2. 💡 Light It Up
* **Objective:** Test your reflexes by tapping randomly illuminated matrix cells before they cycle out.
* **Mechanics:** 4 distinct gameplay phases (`L1` to `L4`) that increase grid density (3-card arrays scaling up to `3x3` matrices) while shortening active targets timers. Includes a 3-life framework system, heavy haptic feedback tracking on misses, and audio profiles for transitions.

### 3. 🧠 Quiz Rush
* **Objective:** Answer a 10-question round of trivia drawn dynamically from real-time topics.
* **Mechanics:** Integrates with the **Open Trivia Database API** using asynchronous networking (`async/await`). Automatically handles multiple choice/true-false logic variations and includes string extension formatting to decode complex HTML content. Features custom background panels that flash green/red depending on input accuracy.

---

## 📁 Folder Structure
```text
Class_Task/
├── App/
│   └── Class_TaskApp.swift
├── Models/
│   ├── GameMode.swift
│   ├── GameSession.swift
│   └── TriviaQuestion.swift
├── Resources/
│   ├── Sounds/
│   └── Assets.xcassets
├── Services/
│   ├── LocationService.swift
│   ├── NotificationService.swift
│   └── TriviaAPI.swift
├── ViewModels/
│   ├── LightItUpVM.swift
│   ├── QuizRushVM.swift
│   ├── StatsVM.swift
│   └── TapFrenzyVM.swift
└── Views/
    ├── Games/
    │   ├── LightItUpView.swift
    │   ├── LoadingScreen.swift
    │   ├── QuizRushView.swift
    │   └── TapFrenzyView.swift
    ├── Shared/
    │   ├── ResultView.swift
    │   └── ScoreBadge.swift
    └── Tabs/
        ├── HomeTab.swift
        ├── MapTab.swift
        ├── SettingsTab.swift
        └── StatsTab.swift
```
### 🗺️ Extended Framework Functions

* **🏆 Stats & Interactive Analytics Dashboard:** * Integrated with custom SwiftUI Charts layouts. Features filtering options to view total matches played, absolute maximum records, historical performance bar graphs (BarMark), and a historical match timeline.

* **📍 Game Map Pinning Engine:** * Utilizes Apple's native MapKit and CoreLocation hardware frameworks. Automatically asks for authorization upon initialization (requestWhenInUseAuthorization). Dropping an arcade pin (Marker) displays specific game descriptions, date timestamps, exact score properties, and signal radius details (horizontalAccuracy).

* **🎵 Media System & Audio Pipeline:** * Built using AVFoundation. Runs background ambient loops that handle interruptions gracefully alongside other apps.

### 🏗️ Architectural Overview (MVVM)

The app follows standard development separation concepts to keep logic decoupleable and easy to maintain:

* **Models:** * Strongly-typed structs conforming to Codable and Identifiable for parsing server responses cleanly.
* **ViewModels:** * ObservableObject controllers utilizing @Published state tracking variables. Marked with @MainActor keywords to guarantee 
thread-safe layout operations away from background threads.
* **Views:** * Structural layers parsing system properties via standard bindings (@StateObject, @AppStorage, and @Environment).

### 🌐 External APIs Used

Open Trivia Database (OpenTDB)
URL: https://opentdb.com/
Description: Provides dynamic trivia questions, categories, and difficulties fetched via REST API endpoints.

### 🔐 Required System Permissions

Location Services (NSLocationWhenInUseUsageDescription): Required to fetch coordinates and drop match markers on the arcade statistics map upon finishing a session.
Notifications (UNUserNotificationCenter): Used to send local notifications and gameplay reminders to players.

### ⚠️ App Limitations

* **Active Internet Connection:** *  Required to fetch live trivia question packs from the OpenTDB API during Quiz Rush sessions.
* **No Authentication:** *  Runs completely locally without user accounts, backend registration, or remote profile cloud sync.
* **Language Support:** *  English-only interface and trivia data payload.

### 🔊 Credits & Attributions

* **Game Over Sound Effect:** *  Pixabay Sound Effects
* **Background & Level Up Music:** *  Free To Use Music

### 🛠️ Requirements & Technical Specs

* **IDE:** * Xcode 15.0 or newer
* **Language:** * Swift 5.9+
* **Deployment Target:** * iOS 17.0+
* **Dependencies:** * None (Relies entirely on native system frameworks)

### 📝 Setup Instructions

Clone or extract the project source code workspace folder onto your macOS disk.
Open the project via the Class_Task.xcodeproj file path configuration launcher.
Select your designated Simulator instance context environment configuration or your physical deployment device.
Go to Product > Clean Build Folder (Cmd + Shift + K).
Press Run (Cmd + R) to build and start playing!

### Reflection

Taking on this project without any background in Swift was quite a personal challenge. Getting used to a completely new language, syntax and framework (SwiftUI) meant I had to keep solving problems and learning the basics constantly.
The weekly check ins gave me clear guidance and ongoing feedback. This step-by-step review helped me stay on track and gradually get a better view of Swift best practices.
When I ran into unexpected bugs and compiler errors, I used technical documentation, developer forums and online resources to figure things out. I learned how to debug tricky issues, find their root causes and write cleaner code to avoid similar problems later on.
In the end, getting over these challenges turned a tough task into a rewarding experience, giving me a solid foundation in Swift and iOS app development.

---

## ⚖️ Educational Disclaimer

This application was developed solely for academic and educational purposes as part of coursework. All third-party media, audio assets, and external API services (such as OpenTDB) used throughout this project are property of their respective owners and are utilized under fair use guidelines for educational demonstration. Any omitted attributions or unintended omissions are strictly unintentional.
