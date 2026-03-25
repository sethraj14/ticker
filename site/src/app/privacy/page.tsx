import { SITE } from "@/lib/constants"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: `Privacy Policy — ${SITE.name}`,
}

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-[#09090b] text-zinc-300">
      <div className="mx-auto max-w-3xl px-6 py-24">
        <h1 className="text-3xl font-bold text-white mb-2">Privacy Policy</h1>
        <p className="text-zinc-500 mb-12">Last updated: March 25, 2026</p>

        <div className="space-y-8 leading-relaxed">
          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              What Ticker Does
            </h2>
            <p>
              Ticker is a macOS menu bar application that displays your upcoming
              calendar events and provides one-click meeting join functionality.
              It connects to Google Calendar and optionally Apple Calendar to
              fetch your events.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              Data We Access
            </h2>
            <ul className="list-disc pl-6 space-y-2">
              <li>
                <strong className="text-white">Google Calendar events:</strong>{" "}
                Event titles, times, attendees, meeting URLs, and calendar
                metadata. Accessed via the Google Calendar API with your
                explicit OAuth consent.
              </li>
              <li>
                <strong className="text-white">Google account email:</strong>{" "}
                Used solely to identify your connected accounts within the app.
              </li>
              <li>
                <strong className="text-white">
                  Apple Calendar events (Pro):
                </strong>{" "}
                Event data from your local Apple Calendar, accessed via the
                EventKit framework with your macOS permission.
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              Where Your Data Is Stored
            </h2>
            <p>
              <strong className="text-white">
                All data stays on your device.
              </strong>{" "}
              Ticker stores calendar data, OAuth tokens, and preferences locally
              in your macOS Application Support directory. We do not operate any
              servers that receive, store, or process your calendar data.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              What We Do Not Do
            </h2>
            <ul className="list-disc pl-6 space-y-2">
              <li>We do not send your data to any server we operate</li>
              <li>We do not sell, share, or monetize your data</li>
              <li>We do not use analytics or tracking in the app</li>
              <li>We do not display advertising</li>
              <li>
                We do not access your calendar data beyond what is displayed in
                the app
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              Third-Party Services
            </h2>
            <ul className="list-disc pl-6 space-y-2">
              <li>
                <strong className="text-white">Google Calendar API:</strong>{" "}
                Used to fetch your events. Subject to{" "}
                <a
                  href="https://policies.google.com/privacy"
                  className="text-blue-400 underline underline-offset-2"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Google&apos;s Privacy Policy
                </a>
                .
              </li>
              <li>
                <strong className="text-white">Lemon Squeezy:</strong> Used for
                Pro license purchases. Payment processing is handled entirely by
                Lemon Squeezy as Merchant of Record. Subject to{" "}
                <a
                  href="https://www.lemonsqueezy.com/privacy"
                  className="text-blue-400 underline underline-offset-2"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Lemon Squeezy&apos;s Privacy Policy
                </a>
                .
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              License Key Data
            </h2>
            <p>
              When you purchase Ticker Pro, Lemon Squeezy generates a license
              key. This key and your associated email are stored locally on your
              device for activation purposes. The key is validated once against
              Lemon Squeezy&apos;s API during activation; after that, the app
              works offline.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">Contact</h2>
            <p>
              For privacy-related questions, reach out at{" "}
              <a
                href="mailto:rajdeepseth007@gmail.com"
                className="text-blue-400 underline underline-offset-2"
              >
                rajdeepseth007@gmail.com
              </a>
              .
            </p>
          </section>
        </div>
      </div>
    </main>
  )
}
