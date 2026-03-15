# Ticker

**Your meetings, always in sight.**

Ticker is a native macOS menu bar app that keeps your calendar front and center. No more switching tabs to check when your next meeting is — Ticker shows a live countdown right in your menu bar, and a beautiful day view one click away.

![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue) ![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange) ![License: MIT](https://img.shields.io/badge/License-MIT-green)

---

## Why I Built This

I was tired of the context switch. Every 30 minutes I'd open Google Calendar in my browser just to check "wait, when's my next meeting?" — and then get sucked into 15 tabs. I wanted something that just *sits there* and tells me what's coming up, without asking for my attention.

Apps like Fantastical exist but they're paid, bloated, and do way more than I need. I just wanted:
- A countdown in my menu bar
- A quick glance at my day
- A "Join" button when it's time

So I built Ticker. It's fast, native, free, and open source.

---

## Features

**Menu Bar Countdown**
- Shows `"Standup in 23m"` right in your menu bar
- Ticks every second when under a minute: `"Standup in 45s"`
- Shows a calendar icon when there are no upcoming meetings

**Day View**
- Google Calendar-style vertical timeline
- Meeting blocks sized proportional to duration
- Color-coded by calendar
- Red "now" line showing current time
- Navigate between days with back/next
- Today/Yesterday/Tomorrow labels

**All Your Calendars**
- Primary, shared, subscribed calendars
- Holidays (Indian holidays, etc.)
- Apple Calendar integration (optional)
- Color-coded per calendar source

**Join Meetings**
- Video icon on each meeting block to join instantly
- Click any meeting to see it in the join section
- Bottom bar shows next up with a prominent "Join" button
- Opens Google Meet, Zoom, or Teams links

**Notifications**
- Native macOS notifications before meetings
- Configurable reminder times (default: 10 minutes)
- "Join Meeting" action button right on the notification
- Add multiple reminder intervals

**Settings**
- Google account sign in/out
- Apple Calendar toggle
- Configurable notification times
- Launch at login

---

## Screenshots

*Coming soon — the app is minimal and beautiful, trust me.*

---

## Installation

### Build from Source

**Requirements:** macOS 13+, Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
# Clone
git clone https://github.com/sethraj14/ticker.git
cd ticker

# Install XcodeGen if you don't have it
brew install xcodegen

# Set up Google OAuth credentials
cp Ticker/Config.xcconfig.example Ticker/Config.xcconfig
# Edit Config.xcconfig with your Google OAuth client ID and secret

# Generate Xcode project & build
xcodegen generate
xcodebuild -project Ticker.xcodeproj -scheme Ticker -configuration Release build

# Run
open ~/Library/Developer/Xcode/DerivedData/Ticker-*/Build/Products/Release/Ticker.app

# Or copy to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/Ticker-*/Build/Products/Release/Ticker.app /Applications/
```

### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a project (or use existing)
3. Enable **Google Calendar API**
4. Create OAuth 2.0 credentials (Desktop app type)
5. Add your client ID and secret to `Ticker/Config.xcconfig`:

```
GOOGLE_CLIENT_ID = your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET = your-client-secret
```

---

## Architecture

```
Ticker/
├── TickerApp.swift              # @main — MenuBarExtra with .window style
├── Views/
│   ├── PopoverView.swift        # Main popup container
│   ├── DayTimelineView.swift    # Scrollable 24h timeline with hour grid
│   ├── MeetingBlockView.swift   # Color-coded meeting blocks
│   ├── JoinSection.swift        # "Up Next" with Join button
│   ├── DayNavigationBar.swift   # ◀ Today ▶ header
│   └── SettingsView.swift       # Accounts, notifications, general
├── ViewModels/
│   └── CalendarViewModel.swift  # State, timers, caching, fetch logic
├── Services/
│   ├── GoogleCalendarService.swift   # OAuth + Calendar API (all calendars)
│   ├── EventKitService.swift         # Apple Calendar via EventKit
│   ├── NotificationService.swift     # UNUserNotificationCenter
│   └── LoopbackHTTPServer.swift      # OAuth callback server
├── Models/
│   └── CalendarEvent.swift      # Unified event model
└── Helpers/
    └── KeychainHelper.swift     # File-based token storage
```

**Key design decisions:**
- **SwiftUI + MenuBarExtra** — native macOS 13+ API, no AppKit hacks
- **No dock icon** — `LSUIElement = true`, pure menu bar utility
- **File-based token storage** — avoids macOS Keychain password popups on unsigned builds
- **Sliding window cache** — prefetches ±2 days for instant navigation
- **Debounced navigation** — rapid next/prev clicks only fetch the final date
- **Concurrent calendar fetching** — all Google calendars fetched in parallel via TaskGroup

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5.9 |
| UI | SwiftUI (macOS 13+) |
| Menu Bar | MenuBarExtra (.window style) |
| Calendar API | Google Calendar REST v3 |
| Apple Calendar | EventKit |
| Auth | OAuth 2.0 PKCE (loopback redirect) |
| Notifications | UNUserNotificationCenter |
| Build | XcodeGen |

---

## Roadmap

- [ ] Multiple Google account support
- [ ] Calendar selection (show/hide specific calendars)
- [ ] Keyboard shortcuts (next/prev day, join next meeting)
- [ ] Custom app icon
- [ ] Homebrew cask distribution
- [ ] Week view
- [ ] Meeting conflict detection

---

## Contributing

Contributions are welcome! This is a personal project I use daily, but if you find it useful:

1. Fork the repo
2. Create a feature branch (`feat/your-feature`)
3. Commit with conventional commits
4. Open a PR

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Credits

Built by [Rajdeep Gupta](https://github.com/sethraj14) with the help of Claude Code.

*Because checking your calendar shouldn't require opening a browser.*
