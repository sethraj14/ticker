# Ticker Ownership

## Critical Modules
| Module | Risk | Why |
|--------|------|-----|
| GoogleCalendarService | HIGH | OAuth tokens, API keys, user calendar data |
| KeychainHelper | HIGH | Secure credential storage |
| NotificationService | MEDIUM | User-facing notifications, timing accuracy |

## Safe Modules
| Module | Risk |
|--------|------|
| Views/* | LOW |
| Models/CalendarEvent | LOW |
| EventKitService | LOW |
| CalendarViewModel | LOW |
