export const SITE = {
  name: "Ticker",
  tagline: "Your next meeting, always in sight.",
  description:
    "A beautiful menu bar calendar for macOS. Live countdown, one-click join, and full event management — create, drag, RSVP, all from your menu bar. Free forever, Pro for power users.",
  url: "https://getticker.app",
  github: "https://github.com/sethraj14/ticker",
  twitter: "https://x.com/rajdeepseth",
  lemonsqueezy: "https://ticker.lemonsqueezy.com/buy/ticker-pro",
  downloadUrl: "https://github.com/sethraj14/ticker/releases/latest",
} as const

export const PRICING = {
  free: {
    name: "Free",
    price: "$0",
    description:
      "A beautiful read-only calendar that keeps you on time.",
    features: [
      "Menu bar countdown timer",
      "One-click meeting join",
      "Google Calendar day timeline",
      "Event details & attendee list",
      "RSVP status on events",
      "First-launch onboarding",
    ],
  },
  pro: {
    name: "Pro",
    price: "$7.99",
    priceNote: "One-time purchase. No subscription.",
    description: "Full calendar management from your menu bar.",
    features: [
      "Everything in Free",
      "Create, edit & delete events",
      "NLP quick-add (\"Standup 3pm 45m\")",
      "Click or drag to create on timeline",
      "Drag to resize & move events",
      "RSVP — respond Going/Maybe/No",
      "Guest management with autocomplete",
      "Multiple Google accounts",
      "Apple Calendar sync",
      "Day navigation (past/future)",
      "Smart notifications",
    ],
  },
} as const

export const FEATURES = [
  // Free features
  {
    title: "Live Countdown",
    description:
      "See exactly how long until your next meeting — down to the second. Always visible in your menu bar.",
    icon: "Timer",
    isPro: false,
  },
  {
    title: "One-Click Join",
    description:
      "Google Meet, Zoom, Teams — click the button, you're in. No hunting for links in emails.",
    icon: "Video",
    isPro: false,
  },
  {
    title: "Beautiful Day Timeline",
    description:
      "A Google Calendar-style timeline right in your menu bar. Color-coded events, overlapping columns, now-line.",
    icon: "Calendar",
    isPro: false,
  },
  // Pro features
  {
    title: "Create Events Instantly",
    description:
      "Click any empty slot to create. Or type \"Team standup 3pm 45m\" — NLP parses it automatically. Drag on the timeline to set duration visually.",
    icon: "Plus",
    isPro: true,
  },
  {
    title: "Drag to Resize & Move",
    description:
      "Drag the bottom edge to resize. Grab the color bar to move. Smooth 60fps, snaps to 15-min grid. Just like Google Calendar.",
    icon: "Move",
    isPro: true,
  },
  {
    title: "RSVP from Menu Bar",
    description:
      "See who's accepted, declined, or tentative — right on the event. Tap Going, Maybe, or No without opening a browser.",
    icon: "CheckCircle",
    isPro: true,
  },
  {
    title: "Guest Management",
    description:
      "Add attendees by email with autocomplete from recent contacts. See each guest's RSVP status at a glance.",
    icon: "Users",
    isPro: true,
  },
  {
    title: "Multiple Accounts",
    description:
      "Work + personal calendars in one view. Add Apple Calendar alongside Google. One unified timeline.",
    icon: "Layers",
    isPro: true,
  },
  {
    title: "Day Navigation & Notifications",
    description:
      "Browse any day — past or future. Get native macOS notifications before meetings with configurable lead times.",
    icon: "Bell",
    isPro: true,
  },
] as const

export const FAQ = [
  {
    q: "Is it really a one-time purchase?",
    a: "Yes. Pay once, use forever. No subscriptions, no annual renewals. Future updates included.",
  },
  {
    q: "What can I do with the free version?",
    a: "Everything you need to stay on time: live countdown, one-click meeting join, full day timeline with event details and attendee lists. Free feels complete, not crippled.",
  },
  {
    q: "What does Pro unlock?",
    a: "Full calendar management — create, edit, delete events. NLP quick-add, drag-to-create, drag-to-resize, drag-to-move, RSVP responses, guest management, multiple accounts, Apple Calendar, and day navigation.",
  },
  {
    q: "Does it work offline?",
    a: "The free tier works with cached events. Pro activation requires internet once — after that, it works offline.",
  },
  {
    q: "Which calendars are supported?",
    a: "Google Calendar (free) and Apple Calendar (Pro). Outlook support is planned for a future update.",
  },
  {
    q: "What about refunds?",
    a: "Full refund within 14 days, no questions asked. Contact us and we'll process it immediately.",
  },
  {
    q: "Can I create and manage events?",
    a: "Yes! With Pro, you can create events via NLP or manual form, edit times and details, manage guest lists, RSVP, and drag events to resize or reschedule — all from your menu bar.",
  },
  {
    q: "Is it on the Mac App Store?",
    a: "Not yet — direct download for now. App Store version is coming soon.",
  },
] as const
