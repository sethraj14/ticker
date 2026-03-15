# CalendarBar Architecture

## Overview
Native macOS menu bar calendar app built with SwiftUI. Shows upcoming meeting countdown in menu bar, Google Calendar-style day view in popup, and native notifications with join buttons.

## Tech Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (macOS 13+)
- **Menu Bar:** MenuBarExtra with .window style
- **Calendar Sources:** Google Calendar REST API + Apple EventKit
- **Auth:** AppAuth (OAuth2 PKCE) for Google
- **Storage:** Keychain (tokens), UserDefaults (preferences)
- **Notifications:** UNUserNotificationCenter

## Key Components

### CalendarBarApp.swift
Entry point. Uses `MenuBarExtra` scene with dynamic label text from `CalendarViewModel`. Style is `.window` for custom popup panel.

### CalendarViewModel
Central state manager:
- Holds merged `[CalendarEvent]` from all sources
- Runs timer for menu bar countdown (60s/1s adaptive)
- Manages selected day for navigation
- Triggers notification scheduling on event changes

### GoogleCalendarService
- OAuth2 PKCE flow via AppAuth library
- REST API calls to Google Calendar v3
- Polls every 5 minutes + on wake
- Tokens stored in Keychain

### EventKitService
- Reads Apple Calendar via EventKit framework
- Listens for EKEventStoreChanged notifications
- Requires NSCalendarsFullAccessUsageDescription

### NotificationService
- Schedules UNNotifications at user-configured intervals
- Registers "JOIN" action category
- Handles notification response → opens meeting URL

## Data Model
```swift
struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let meetingURL: URL?
    let source: CalendarSource  // .google, .apple
    let calendarColor: Color
    let attendees: [String]
    let location: String?
    let notes: String?
}
```

## Permissions
- `NSCalendarsFullAccessUsageDescription` — Apple Calendar
- `com.apple.security.network.client` — Google API calls
- `LSUIElement = true` — no dock icon
