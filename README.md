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

## 🗺️ Extended Framework Functions

* **🏆 Stats & Interactive Analytics Dashboard:** Integrated with custom `SwiftUI Charts` layouts. Features filtering options to view total matches played, absolute maximum records, historical performance bar graphs (`BarMark`), and a historical match timeline.
* **📍 Game Map Pinning Engine:** Utilizes Apple's native `MapKit` and `CoreLocation` hardware frameworks. Automatically asks for authorization upon initialization (`requestWhenInUseAuthorization`). Dropping an arcade pin (`Marker`) displays specific game descriptions, date timestamps, exact score properties, and signal radius details (`horizontalAccuracy`).
* **🎵 Media System & Audio Pipeline:** Built using `AVFoundation`. Runs background ambient loops that handle interruptions gracefully alongside other apps.

---

## 🏗️ Architectural Overview (MVVM)

The app follows standard development separation concepts to keep logic decoupleable and easy to maintain:

* **Models:** Strongly-typed structs conforming to `Codable` and `Identifiable` for parsing server responses cleanly.
* **ViewModels:** `ObservableObject` controllers utilizing `@Published` state tracking variables. Marked with `@MainActor` keywords to guarantee thread-safe layout operations away from background threads.
* **Views:** Structural layers parsing system properties via standard bindings (`@StateObject`, `@AppStorage`, and `@Environment`).

---

## 🛠️ Requirements & Technical Specs

* **IDE:** Xcode 15.0 or newer
* **Language:** Swift 5.9+
* **Deployment Target:** iOS 17.0+
* **Dependencies:** None (Relies entirely on native system frameworks)

---

## 📝 Setup Instructions

1. Clone or extract the project source code workspace folder onto your macOS disk.
2. Open the project via the **`Class_Task.xcodeproj`** file path configuration launcher.
3. Select your designated Simulator instance context environment configuration or your physical deployment device.
4. Go to **Product** > **Clean Build Folder** (`Cmd + Shift + K`).
5. Press **Run** (`Cmd + R`) to build and start playing!
```
