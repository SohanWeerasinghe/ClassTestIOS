# Light It Up - iOS Arcade Game

A fast-paced grid-tapping reaction game built using **SwiftUI**, **Combine**, and **AVFAudio**. The game tests your speed and accuracy as you tap highlighted cards before they dim. The difficulty increases automatically over a single 60-second round, adding more cards and faster lighting intervals as you progress through the levels.

This project was built as part of an iOS App Development class task.

---

## 🎮 How to Play

1. **Start the Game:** When the view loads, a 60-second countdown timer starts.
2. **Tap Active Targets:** Cards will randomly light up based on a level-specific duration. Tap the highlighted card to score **+10 points**.
3. **Avoid Misses:** Tapping a dim/inactive card will penalize you by taking away one of your **3 lives**.
4. **Survive and Advance:** Keep your score high and survive until the timer hits 0 or your lives run out!

---

## 🚀 Game Features

* **Single-File Architecture:** The entire game logic, model definitions, and UI layouts are neatly combined inside `LightUpLoadingScreen.swift` for easy management.
* **Dynamic Level Progression:** The game scales dynamically across 4 distinct phases inside a single 60-second match:
  * **Level 1 (0–15s):** 3 cards in a row, 1.5s lit window, Green glow.
  * **Level 2 (15–30s):** 4 cards grid (2x2), 1.2s lit window, Blue glow.
  * **Level 3 (30–45s):** 6 cards grid (2x3), 1.0s lit window, Orange glow.
  * **Level 4 (45s–End):** 9 cards grid (3x3), 0.8s lit window with **2 cards lit simultaneously**, Purple glow.
* **3-Lives Health Tracker:** Includes visual heart indicators (`heart.fill` / `heart`) tracking mistakes.
* **Persistent High Scores:** Saves your top score locally using `@AppStorage` so it persists even if the app restarts.
* **Immersive Audio Engine:** Integrated retro sound effects via `AVAudioPlayer` for Level Ups (`.wav`), Health Loss (`.wav`), and Game Over (`.mp3`).
* **Visual Polish:** Level-Up full-screen animated flash overlays and interactive spring animations upon tapping active items.

---

## 🛠️ Code Architecture

The codebase is split into modular components within a single file to keep code execution clear:

1. **`LightUpLoadingScreen` (View):** Handles the layout configuration including the scoreboard panel, health tracker bar, responsive `LazyVGrid` layouts, and game-over popups.
2. **`LightUpCard` (Model):** A simple `Identifiable` data structure managing state elements (`id`, `isLit`).
3. **`GameLevel` (Enum):** Houses level specifications such as grid layouts, countdown intervals, grid column structures, and color themes.
4. **`LightUpGameManager` (ObservableObject ViewModel):** Drives the core game state machine, handling interactive timer binds via Combine framework publishers, score mechanics, sound processing, and collision/tap tracking.

---

## 💻 Tech Stack & Requirements

* **Language:** Swift 5.x
* **UI Framework:** SwiftUI
* **Reactive Framework:** Combine (for asynchronous game loops and clocks)
* **Audio Framework:** AVFAudio (`AVAudioPlayer` & `AVAudioSession`)
* **Minimum iOS Target:** iOS 15.0+
* **IDE:** Xcode 13+

---

## 📝 Setup Instructions

1. Clone or download this repository.
2. Open the project inside Xcode.
3. Make sure the required audio resource clips (`levelcompleted.wav`, `losehealth.wav`, and `gameoverarcade.mp3`) are added directly to your Xcode **Main App Bundle**.
4. Run the app on an iOS Simulator or a physical device.
