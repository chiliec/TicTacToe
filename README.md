# Tic-Tac-Toe

A React Native Tic-Tac-Toe game with an intelligent AI opponent, user profiles, and global leaderboard. Built with TypeScript, React Native, and Swift.

## Features

- **Smart AI Opponent** - AI uses strategy to win and block player moves
- **User Profiles** - Create and manage your player name
- **Game Statistics** - Track wins, losses, streaks, and play time
- **Platform** - Runs on iOS

## Tech Stack

- **UI**: React Native, TypeScript, React Hooks
- **Logic**: Swift, SwiftData, URLSession
- **State Management**: React Native Async Bridge
- **Data Persistence**: SwiftData (local), ~~REST API (leaderboard)~~

## Prerequisites

- Node.js 18+ and npm/yarn
- Ruby 2.7+ (for CocoaPods)
- Xcode 16+ (for iOS development)

## Installation

### Step 1: Clone and Install Dependencies

```
git clone https://github.com/chiliec/TicTacToe.git
cd TicTacToe
npm install
```

### Step 2: Install CocoaPods

First-time setup:
```bash
bundle install
```

Then install pods:
```bash
bundle exec pod install
```

### Step 3: Start Metro Dev Server

```bash
npm start
```

### Step 4: Build and Run

#### iOS
```bash
npm run ios
```

## Game Rules

- Players take turns marking spaces on a 3×3 grid
- First player to get 3 in a row (horizontal, vertical, or diagonal) wins
- If all 9 squares are filled with no winner, the game is a draw

## Playing

### Starting a Game

Tap any cell to make your move. The game timer starts on your first move. The AI automatically takes its turn after you.

### Viewing Your Stats

- Navigate to the "🏆 Rating" tab to see your stats and compete on the leaderboard
- Stats include: win/loss record, win rate, longest streak, and total playtime

### Changing Your Username

Tap your username in the top-left corner of the game screen to edit it. This is used to track your stats and leaderboard position.

## Troubleshooting

### iOS Build Issues

#### Clean build cache
rm -rf ~/Library/Developer/Xcode/DerivedData

#### Reinstall pods
`bundle exec pod install --repo-update`

### App Crashes on Startup

- Check that CocoaPods dependencies are installed: `bundle exec pod install`
- Verify Xcode/Android SDK are up to date
- Clear Metro cache: `npm start -- --reset-cache`

## Future Enhancements

- [ ] Multiplayer support (local and online)
- [ ] Different difficulty levels
- [ ] Sound effects and animations
- [ ] Persistent leaderboard synchronization

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add my feature'`
4. Push to branch: `git push origin feature/my-feature`
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues or questions, please open a GitHub issue.
