# CalendarBar — macOS Menu Bar Calendar

## What Is This
Native macOS menu bar app that shows upcoming meeting countdown, Google Calendar-style day view, and join notifications. Built with SwiftUI targeting macOS 13+.

## Tech Stack
- **Language:** Swift 5.9+
- **UI:** SwiftUI (MenuBarExtra API)
- **Calendar:** Google Calendar REST API + Apple EventKit
- **Auth:** AppAuth (OAuth2 PKCE)
- **Notifications:** UNUserNotificationCenter
- **Storage:** Keychain (tokens), UserDefaults (prefs)

## Project Structure
```
CalendarBar/
├── CalendarBarApp.swift          # @main entry, MenuBarExtra
├── Views/                        # All SwiftUI views
├── ViewModels/                   # CalendarViewModel
├── Services/                     # Google, EventKit, Notifications
├── Models/                       # CalendarEvent unified model
├── Helpers/                      # KeychainHelper
└── Info.plist                    # Permissions, LSUIElement
```

## Key Files
- `docs/plans/2026-03-15-calendarbar-design.md` — Full design doc
- `knowledge/architecture.md` — Architecture and data flow
- `knowledge/ownership.md` — Critical module ownership

## Conventions
- SwiftUI views are small, composable
- All calendar data flows through CalendarViewModel
- Google tokens stored in Keychain, never UserDefaults
- No dock icon (LSUIElement = true)

## Build & Run
```bash
open CalendarBar.xcodeproj
# Cmd+R to build and run
```
