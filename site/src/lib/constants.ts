export const SITE = {
  name: "Ticker",
  tagline: "Your next meeting, always in sight.",
  description:
    "A beautiful menu bar calendar for macOS that counts down to your next meeting. One click to join. Free forever, Pro for power users.",
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
      "Everything you need to stay on top of your next meeting.",
    features: [
      "Menu bar countdown timer",
      "One-click meeting join",
      "Google Calendar day view",
      "Single account",
    ],
  },
  pro: {
    name: "Pro",
    price: "$7.99",
    priceNote: "One-time purchase. No subscription.",
    description: "For power users who live in their calendar.",
    features: [
      "Everything in Free",
      "Multiple Google accounts",
      "Apple Calendar sync",
      "Native macOS notifications",
      "Day navigation (browse past/future)",
      "Customizable appearance",
    ],
  },
} as const

export const FEATURES = [
  {
    title: "Live Countdown",
    description:
      "See exactly how long until your next meeting — down to the second. No more mental math.",
    icon: "Timer",
    isPro: false,
  },
  {
    title: "One-Click Join",
    description:
      "Google Meet, Zoom, Teams — click the button, you're in. No hunting for links.",
    icon: "Video",
    isPro: false,
  },
  {
    title: "Beautiful Day View",
    description:
      "A Google Calendar-style timeline right in your menu bar. See your entire day at a glance.",
    icon: "Calendar",
    isPro: false,
  },
  {
    title: "Multiple Accounts",
    description:
      "Work + personal calendars, all in one place. No switching between accounts.",
    icon: "Users",
    isPro: true,
  },
  {
    title: "Smart Notifications",
    description:
      "Native macOS notifications with a 'Join Meeting' button. Configurable lead times.",
    icon: "Bell",
    isPro: true,
  },
  {
    title: "Apple Calendar Sync",
    description:
      "See events from your Apple Calendar alongside Google. One unified timeline.",
    icon: "Repeat",
    isPro: true,
  },
] as const

export const FAQ = [
  {
    q: "Is it really a one-time purchase?",
    a: "Yes. Pay once, use forever. No subscriptions, no annual renewals. Future updates included.",
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
    q: "Will there be an iOS version?",
    a: "We're considering it! Sign up for updates to be the first to know.",
  },
  {
    q: "Is it on the Mac App Store?",
    a: "Not yet — direct download for now. App Store version is coming soon.",
  },
] as const
