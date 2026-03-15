# Contributing to Ticker

Thanks for your interest in contributing to Ticker! Here's how to get started.

## Setup

1. **Fork and clone** the repo
2. **Install XcodeGen**: `brew install xcodegen`
3. **Set up credentials**: Copy `Ticker/Config.xcconfig.example` to `Ticker/Config.xcconfig` and add your Google OAuth credentials
4. **Generate project**: `xcodegen generate`
5. **Open in Xcode**: `open Ticker.xcodeproj`
6. **Build and run**: `Cmd+R`

## Development Guidelines

- **Swift 5.9+** with strict typing
- **SwiftUI** for all views — no AppKit unless absolutely necessary
- **Small, composable views** — keep files under 300 lines
- **Conventional commits**: `feat:`, `fix:`, `chore:`, `refactor:`
- **One PR per feature** — keep changes focused

## Architecture

- **ViewModel** (`CalendarViewModel`) owns all state and fetch logic
- **Services** handle external integrations (Google, EventKit, Notifications)
- **Views** are pure — they receive data and emit actions
- **Models** are simple structs — no business logic

## What to Work On

Check the [Issues](https://github.com/sethraj14/ticker/issues) tab for open tasks. Good first issues are labeled accordingly.

Key areas that could use help:
- Multiple Google account support
- Calendar selection UI
- Keyboard shortcuts
- App icon design
- Week view

## Submitting Changes

1. Create a feature branch: `git checkout -b feat/your-feature`
2. Make your changes
3. Build and test: `xcodebuild -scheme Ticker build`
4. Commit with conventional commits
5. Push and open a PR

## Code of Conduct

Be respectful. Build cool things. Help others.
