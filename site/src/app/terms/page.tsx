import { SITE } from "@/lib/constants"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: `Terms of Service — ${SITE.name}`,
}

export default function TermsPage() {
  return (
    <main className="min-h-screen bg-[#09090b] text-zinc-300">
      <div className="mx-auto max-w-3xl px-6 py-24">
        <h1 className="text-3xl font-bold text-white mb-2">
          Terms of Service
        </h1>
        <p className="text-zinc-500 mb-12">Last updated: March 25, 2026</p>

        <div className="space-y-8 leading-relaxed">
          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              1. Agreement
            </h2>
            <p>
              By downloading or using Ticker (&quot;the App&quot;), you agree to
              these terms. If you do not agree, do not use the App.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              2. License Grant
            </h2>
            <p>
              <strong className="text-white">Free tier:</strong> You are granted
              a free, non-exclusive, non-transferable license to use Ticker for
              personal and commercial purposes on any number of Macs you own.
            </p>
            <p className="mt-3">
              <strong className="text-white">Pro tier:</strong> Upon purchasing
              a valid license key, you are granted a perpetual, non-exclusive
              license to use Ticker Pro on up to 3 Macs. The license is tied to
              your purchase and is non-transferable.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              3. Purchases and Refunds
            </h2>
            <p>
              Pro licenses are sold through Lemon Squeezy, who acts as the
              Merchant of Record. All payments, taxes, and invoicing are handled
              by Lemon Squeezy.
            </p>
            <p className="mt-3">
              <strong className="text-white">Refund policy:</strong> Full refund
              within 14 days of purchase, no questions asked. Contact{" "}
              <a
                href="mailto:rajdeepseth007@gmail.com"
                className="text-blue-400 underline underline-offset-2"
              >
                rajdeepseth007@gmail.com
              </a>{" "}
              or request through Lemon Squeezy.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              4. Updates
            </h2>
            <p>
              Your Pro license includes all future updates to Ticker. We may
              release new major versions as separate products in the future,
              which would require a new purchase. Current functionality will
              continue to work regardless.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              5. Restrictions
            </h2>
            <p>You may not:</p>
            <ul className="list-disc pl-6 space-y-2 mt-2">
              <li>
                Reverse-engineer, decompile, or disassemble the App (except
                where permitted by law)
              </li>
              <li>Share, resell, or distribute license keys</li>
              <li>Use the App to violate any applicable laws</li>
              <li>
                Remove or alter any proprietary notices in the App
              </li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              6. Disclaimer of Warranties
            </h2>
            <p>
              Ticker is provided &quot;as is&quot; without warranty of any kind,
              express or implied. We do not warrant that the App will be
              error-free, uninterrupted, or meet your specific requirements. Use
              at your own risk.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              7. Limitation of Liability
            </h2>
            <p>
              To the maximum extent permitted by law, we shall not be liable for
              any indirect, incidental, special, consequential, or punitive
              damages arising from your use of the App, including but not
              limited to missed meetings, lost data, or business interruption.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              8. Termination
            </h2>
            <p>
              We reserve the right to revoke license keys that are found to be
              shared, resold, or obtained fraudulently. Upon termination, Pro
              features will be disabled, but the free tier will continue to
              function.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              9. Changes to Terms
            </h2>
            <p>
              We may update these terms from time to time. Changes will be
              posted on this page with an updated date. Continued use of the App
              after changes constitutes acceptance of the new terms.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-white mb-3">
              10. Contact
            </h2>
            <p>
              Questions about these terms? Contact{" "}
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
