# 🎮 MiniGame App

**MiniGame App** is an iOS gaming collection featuring Conway's Game of Life, a Chess engine with AI opponent, and a two-player chess mode.  
This project was developed as a SwiftUI exploration into interactive simulations, algorithmic thinking, and game development.

---

## 📸 Screenshots

<p align="center">
  <img src="photo/readme/Collage2.png" width="300" alt="Game of Life View">
  <img src="photo/readme/Collage1.png" width="300" alt="Chess View">
  <img src="photo/readme/Collage3.png" width="300" alt="Chess Bot View">
</p>
<p align="center">
  <em>Game of Life &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chess Friend &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Chess Bot</em>
</p>

---

## 🏛️ Project Vision

> *"Three games, one app — where cellular automata meets chess strategy."*

The app brings together two distinct worlds: the mesmerizing emergent behavior of cellular automata and the timeless strategic depth of chess. Whether you're watching patterns evolve or challenging an AI opponent, MiniGame App offers a playground for curiosity and tactical thinking.

---

## ✨ Features

Here's what you can do with MiniGame App:

### 🧬 Game of Life
- **Cellular Automaton Simulation** – Watch Conway's Game of Life evolve in real-time
- **Interactive Grid** – Tap cells to create custom patterns (gliders, oscillators, still lifes)
- **Play/Pause Controls** – Run the simulation or step through generations manually
- **Random Reset** – Generate new random configurations with a single tap
- **Animated Background** – Immersive DotLottie animation brings the experience to life

### ♟️ Chess Friend (Two-Player)
- **Local Multiplayer** – Play chess with a friend on the same device
- **Full Chess Rules** – Complete move validation including castling, en passant, and pawn promotion
- **Visual Move Indicators** – Green highlights show valid moves for selected pieces
- **Check & Checkmate Detection** – Automatic game end detection with winner announcement
- **Move History** – Undo/Redo functionality to correct mistakes
- **Captured Pieces Display** – Track which pieces have been taken

### 🤖 Chess Bot (AI Opponent)
- **Single-Player Chess** – Challenge an AI opponent with adjustable difficulty
- **Three Difficulty Levels**:
  - **Easy** (Depth 1) – Beginner-friendly, makes occasional mistakes
  - **Medium** (Depth 3) – Balanced challenge for casual players
  - **Hard** (Depth 5) – Serious opponent for experienced players
- **Minimax Algorithm** – AI uses alpha-beta pruning for efficient decision making
- **Hint System** – Get AI-suggested moves when you're stuck
- **Themed Boards** – Choose from Classic, Wood, or Purple themes

### 🎨 Shared Features
- **Dark Mode** – Optimized for both light and dark environments
- **Haptic Feedback** – Tactile responses for moves and selections
- **Sound Effects** – Ambient music and move sounds (toggleable)
- **Persistent Settings** – Difficulty, theme, and audio preferences saved via UserDefaults

---

## 🛠️ Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | 100% Declarative UI framework |
| **MVVM** | Architecture with `@StateObject` & `@Published` for reactive updates |
| **UserDefaults & @AppStorage** | Persistent user preferences (difficulty, theme, sound) |
| **Lottie (DotLottie)** | Smooth animated backgrounds |
| **Combine** | Reactive state management |
| **AVFoundation** | Audio playback for music and sound effects |
| **Minimax Algorithm** | AI decision making with alpha-beta pruning |
| **Transposition Table** | Performance optimization for chess AI |

---

## 📖 The Process

I started by designing the **Game of Life** module. The challenge was creating an efficient grid system that updates smoothly. I used a 40x20 grid with cell states stored in a 2D boolean array. The next-generation calculation runs through each cell, counting live neighbors and applying Conway's four rules. The timer-based animation lets users watch evolution in real-time or step through manually.

Next came the **Chess engine** – the most complex part of the project. I modeled the board as an 8x8 array of optional `ChessPiece` objects, each with type, color, position, and move history. Move validation was implemented piece by piece, handling special rules like pawn double-moves, en passant, and castling. Check and checkmate detection required simulating moves to verify if the king remains safe.

The **AI opponent** was built using the Minimax algorithm with alpha-beta pruning for efficiency. The evaluation function assigns point values to pieces (pawn=10, knight=30, bishop=30, rook=50, queen=90, king=900) and sums them with sign based on color. Difficulty levels control search depth (1, 3, or 5 moves ahead). A transposition table caches evaluated positions to avoid redundant calculations.

For the **theming system**, I created a `ThemeManager` that provides different color schemes (Classic, Wood, Purple). The Wood theme uses custom images (`WoodLight` and `WoodDark`) for a realistic wooden board texture.

**Audio integration** added polish: background music loops seamlessly, move sounds trigger on piece placement, and haptic feedback provides physical confirmation. All audio settings are user-controllable via the settings panel.

**Navigation** uses SwiftUI's `NavigationStack` with an enum-based routing system, making it easy to add new games in the future.

---

## 🧠 What I Learned

During this project, I picked up important skills and gained a deeper understanding of iOS development:

### 🗂️ State Management with MVVM
- Using `@StateObject`, `@ObservedObject`, and `@Published` to manage game state across views
- Creating observable models (`ChessGame`, `GameOfLifeModel`) that automatically update the UI

### 🤖 AI Algorithm Implementation
- Building a **Minimax algorithm** with alpha-beta pruning for efficient move searching
- Implementing a **transposition table** to cache evaluated board positions
- Designing an **evaluation function** that considers piece values and board control
- Adjusting AI difficulty through search depth limiting

### 🎨 Custom UI Components
- Building reusable views like `ChessSquareView`, `StyledBoardView`, and `HintBoardPreview`
- Creating dynamic theming with custom color schemes and image-based textures
- Implementing visual move indicators and check highlighting

### 🔊 Audio & Haptics
- Integrating `AVAudioPlayer` for background music and sound effects
- Managing audio state across app sessions with `UserDefaults`
- Adding haptic feedback for tactile user experience

### 🧪 Complex Game Logic
- Implementing **complete chess rules**: castling, en passant, pawn promotion
- Detecting check, checkmate, and stalemate conditions
- Managing move history for undo functionality
- Simulating moves to validate king safety

### 🧬 Cellular Automata
- Implementing Conway's four rules efficiently
- Managing grid-based simulations with timer-driven updates
- Creating interactive tap-to-edit functionality

### 🎯 Navigation Architecture
- Using `NavigationStack` with enum-based routing
- Passing data between views with `@Environment(\.dismiss)`

---

## 🚀 How Can It Be Improved?

- Add **online multiplayer** for chess using GameKit or WebSockets
- Implement **more chess variants** (960, blitz, time controls)
- Add **game replays** to review past matches
- Create **opening book** for AI to play known openings
- Add **more cellular automata rules** (Brian's Brain, Seeds, etc.)
- Implement **pattern library** for Game of Life (glider gun, spaceships, oscillators)
- Add **drag-and-drop** piece movement for more intuitive chess controls
- Create **chess puzzles** with daily challenges
- Add **achievements** and **leaderboards** via Game Center
- Implement **iCloud sync** for settings across devices
- Add **iPad optimization** with split-view support

---

## 🏃‍♂️ Running the Project

To run the project in your local environment, follow these steps:

1. **Clone the repository** to your local machine:
   ```bash
   git clone https://github.com/Leonardo-jfk/MiniGame-App.git

2. **Open the project in Xcode:**
 ```bash
    open GameOfLifeIOS.xcodeproj
 ```
3. Wait for Swift Package Manager to resolve dependencies (Lottie).
4. Select a target (simulator or physical device).
5. Press Run (⌘R) to build and launch the app.


---

⭐ If this project inspires you, consider giving it a star on GitHub!
