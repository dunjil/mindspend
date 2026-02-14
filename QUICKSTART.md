# MindSpend - Quick Start Guide

## What's Been Built

A complete **Daily Expense Tracker** Flutter app with:

✅ **Quick Log Screen** - Fast expense entry with categories and amount input  
✅ **Dashboard** - Summary card and transaction list  
✅ **Streak System** - Habit tracking with 24h/48h grace period logic  
✅ **SQLite Persistence** - All data saved locally  
✅ **Bottom Navigation** - Seamless tab switching  
✅ **Emotion Tagging** - Post-log reflection feature  

## Running the App

### 1. Install Dependencies
```bash
cd /home/duna/StudioProjects/mindspend
flutter pub get
```

### 2. Run on Device/Emulator
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### 3. Build for Release
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Testing the Features

### Quick Log Flow
1. Launch app → Opens on "Log" tab
2. Enter amount (e.g., "25.50")
3. Tap category (e.g., "Food")
4. Transaction auto-saves
5. Streak badge updates
6. Tap "Done for Today"
7. Select emotion (😊/😐/😞)
8. Auto-switches to Dashboard tab

### Dashboard
1. Tap "Dashboard" tab
2. View summary card (Income/Expenses/Net)
3. Scroll through transaction list
4. Verify transactions persist after app restart

### Streak System
1. Log first transaction → Streak shows "1 day streak"
2. Log again within 24h → Streak increments to "2 days"
3. Wait 25h, log → Streak maintains (grace period)
4. Wait 49h, log → Streak resets to "1 day"

## Project Structure

```
lib/
├── core/
│   ├── components/        # Reusable UI components
│   ├── navigation/        # Bottom navigation
│   ├── services/          # Database helper
│   └── theme/            # Colors and themes
├── features/
│   ├── dashboard/        # Dashboard feature
│   ├── streak/           # Streak tracking
│   └── transaction/      # Quick log & transactions
└── main.dart            # App entry point
```

## Next Steps

### Recommended Features
- [ ] Dashboard filtering (by date/category)
- [ ] Insights screen with charts
- [ ] Profile/Settings screen
- [ ] Onboarding flow
- [ ] Export data feature

### Polish
- [ ] Add animations (confetti on streak milestones)
- [ ] Error handling improvements
- [ ] Empty state illustrations
- [ ] Accessibility improvements

## Troubleshooting

### Common Issues

**Build errors:**
```bash
flutter clean
flutter pub get
flutter run
```

**SQLite issues:**
- Database is created at app first launch
- Location: `getDatabasesPath()/mindspend.db`
- To reset: Uninstall and reinstall app

**Streak not updating:**
- Check that StreakController is initialized in MainNavigation
- Verify SharedPreferences permissions

## Architecture

- **State Management**: GetX
- **Database**: SQLite (sqflite)
- **Preferences**: SharedPreferences
- **Responsive Design**: flutter_screenutil (390x844 base)
- **Architecture**: Clean Architecture (Data/Domain/Presentation)
