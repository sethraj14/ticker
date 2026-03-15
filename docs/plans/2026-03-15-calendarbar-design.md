# CalendarBar — Design Document

> Native macOS menu bar calendar app with meeting countdown, day view, and join notifications.

## Problem

Switching to browser/calendar app to check upcoming meetings breaks flow. Need a lightweight, always-visible menu bar utility that shows what's next, counts down, and lets you join with one click.

## Core Features

### 1. Menu Bar Label (Always Visible)
- Shows: `"Standup in 23m"` → `"Standup in 45s"` (ticking every second) → `"Standup NOW"`
- Timer: 60s intervals normally, 1s intervals when < 60s remaining
- No meetings: calendar icon or "No meetings"

### 2. Popup Panel (Click Menu Bar)
Google Calendar-style vertical day view:
- **Hourly grid** — vertical scrollable timeline with hour markers
- **Meeting blocks** — sized proportional to duration, color-coded by calendar
- **Now indicator** — red line showing current time, auto-scrolls to it on open
- **Click meeting block** — expands to show details (attendees, link, description)
- **Day navigation** — ◀ ▶ buttons to browse days, "Today" label
- **Join section** (pinned bottom) — next upcoming meeting: title, time, [Join] button
- **Settings link** — gear icon at bottom

### 3. Notifications
- Configurable notification times (default: 10 minutes before)
- macOS native notifications via UNUserNotificationCenter
- Each notification has "Join" action button → opens meeting URL
- Shows: meeting title + time + "starts in Xm"

### 4. Calendar Sources
- **Google Calendar** (primary) — REST API, OAuth2 PKCE via AppAuth
- **Apple Calendar** (optional) — EventKit framework
- Unified `CalendarEvent` model, deduplicated by title + time

## Architecture

### Tech Stack
- **SwiftUI** — macOS 13+ (MenuBarExtra API)
- **MenuBarExtra(.window)** — custom popover panel
- **AppAuth** — Google OAuth2 PKCE flow
- **EventKit** — Apple Calendar integration
- **UNUserNotificationCenter** — local notifications with actions
- **Keychain** — secure token storage
- **No Dock icon** — `LSUIElement = true`

### Data Flow
```
Google Calendar API  ──┐
                       ├──▶ [CalendarEvent] ──▶ CalendarViewModel ──▶ MenuBar + Popup
Apple EventKit       ──┘                              │
                                                 Timer (1s/60s)
                                                      │
                                            NotificationService
                                            (schedules UNNotifications)
```

### Event Refresh
- Poll Google API every 5 minutes
- Refresh on app wake / system resume
- EventKit uses native change notifications

### Project Structure
```
CalendarBar/
├── CalendarBarApp.swift              # @main, MenuBarExtra scene
├── Views/
│   ├── PopoverView.swift             # Main popup container
│   ├── DayTimelineView.swift         # Scrollable hourly grid
│   ├── MeetingBlockView.swift        # Meeting block on timeline
│   ├── JoinSection.swift             # Bottom "up next" with join
│   ├── DayNavigationBar.swift        # ◀ Today ▶ header
│   └── SettingsView.swift            # Notification prefs, accounts
├── ViewModels/
│   └── CalendarViewModel.swift       # State, timer, event merging
├── Services/
│   ├── GoogleCalendarService.swift   # OAuth + API calls
│   ├── EventKitService.swift         # Apple Calendar access
│   └── NotificationService.swift     # Schedule/manage notifications
├── Models/
│   └── CalendarEvent.swift           # Unified event model
├── Helpers/
│   └── KeychainHelper.swift          # Secure token storage
├── Assets.xcassets/                  # App icon, colors
└── Info.plist                        # LSUIElement, permissions
```

## Key Decisions
- macOS 13+ minimum for MenuBarExtra API
- AppAuth for OAuth (no custom PKCE implementation)
- Keychain for token persistence (not UserDefaults)
- Timer efficiency: 60s → 1s switch based on proximity
- EventKit for Apple Calendar (not CalDAV)
