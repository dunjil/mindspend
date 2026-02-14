# MindSpend - Daily Expense Tracker

A Flutter mobile app for tracking daily expenses with a focus on speed, habit formation, and emotional awareness.

## Features

### ✅ Implemented

- **Quick Log** - Log expenses in under 15 seconds
  - Fast amount input with currency formatting
  - 6 preset categories (Food, Transport, Shopping, Bills, Fun, Home)
  - Auto-save on category selection

- **Emotion Tagging** - Reflect on spending decisions
  - "Was this worth it?" prompt after logging
  - Three emotion options: Good (😊), Neutral (😐), Bad (😞)

- **Streak System** - Build daily logging habits
  - Tracks consecutive days of logging
  - 24-hour increment window
  - 48-hour grace period before reset
  - Visual streak badge with fire emoji 🔥

- **Dashboard** - View spending overview
  - Monthly summary (Income/Expenses/Net)
  - Transaction list with categories and emotions
  - Real-time data from SQLite

- **Data Persistence** - All data saved locally
  - SQLite database for transactions
  - SharedPreferences for streak data

- **Bottom Navigation** - Seamless tab switching
  - Quick Log tab
  - Dashboard tab

## Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Database**: SQLite (sqflite)
- **Responsive Design**: flutter_screenutil (390x844 base)
- **Architecture**: Clean Architecture

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode
- Device or emulator

### Installation

```bash
# Clone the repository
cd /home/duna/StudioProjects/mindspend

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── components/        # Reusable UI components (AmountInput)
│   ├── navigation/        # Bottom navigation setup
│   ├── services/          # Database helper
│   └── theme/            # App colors and themes
├── features/
│   ├── dashboard/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/  # Dashboard UI and logic
│   ├── streak/
│   │   ├── data/          # Streak model and repository
│   │   ├── domain/
│   │   └── presentation/  # Streak badge and controller
│   └── transaction/
│       ├── data/          # Transaction model and SQLite repo
│       ├── domain/
│       └── presentation/  # Quick Log UI and logic
└── main.dart
```

## Usage

1. **Log an Expense**
   - Enter amount
   - Select category
   - Transaction auto-saves

2. **Add Emotion** (Optional)
   - Tap "Done for Today"
   - Select how you feel about the spending
   - Switches to Dashboard

3. **View Dashboard**
   - See monthly summary
   - Browse transaction history
   - Track your streak

## Development

### Run Tests
```bash
flutter test
```

### Build Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Code Analysis
```bash
flutter analyze
```

## Design Principles

- **Speed First**: Log expenses in under 15 seconds
- **Habit Formation**: Streak system encourages daily logging
- **Emotional Awareness**: Reflect on spending decisions
- **Clean Architecture**: Separation of concerns (Data/Domain/Presentation)
- **Material Design**: Follows Material Design 3 principles

## License

This project is for educational purposes.

## Acknowledgments

Built with Flutter and GetX for state management.
