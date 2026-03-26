import { SITE, PRICING } from "@/lib/constants"

export function Pricing() {
  return (
    <section className="py-32 px-6" id="pricing" style={{ background: "var(--t-bg)" }}>
      <div className="max-w-5xl mx-auto text-center mb-16">
        <h2 className="text-4xl font-bold font-headline mb-4" style={{ color: "var(--t-text)" }}>
          Simple, honest pricing.
        </h2>
        <p style={{ color: "var(--t-text-muted)" }}>Pay once, own it forever. No subscriptions, ever.</p>
      </div>

      <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Free */}
        <div className="p-10 rounded-xl flex flex-col" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
          <div className="mb-8">
            <h3 className="font-bold font-headline text-2xl mb-2" style={{ color: "var(--t-text)" }}>Free</h3>
            <div className="text-4xl font-bold font-headline" style={{ color: "var(--t-text)" }}>
              $0<span className="text-lg font-normal" style={{ color: "var(--t-text-muted)" }}> forever</span>
            </div>
          </div>

          <ul className="space-y-4 mb-10 flex-grow">
            {PRICING.free.features.map((feature) => (
              <li key={feature} className="flex items-center gap-3 text-sm" style={{ color: "var(--t-text-secondary)" }}>
                <span style={{ color: "var(--t-accent)" }}>&#10003;</span>
                {feature}
              </li>
            ))}
          </ul>

          <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
            <button className="w-full py-4 rounded-lg font-bold font-headline transition-all" style={{ border: "1px solid var(--t-border)", color: "var(--t-text)" }}>
              Download Now
            </button>
          </a>
        </div>

        {/* Pro */}
        <div className="p-10 rounded-xl flex flex-col relative" style={{ background: "var(--t-bg-card)", border: "2px solid var(--t-pro-border)" }}>
          <div className="absolute -top-4 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-xs font-bold uppercase tracking-wider" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>
            Most Popular
          </div>

          <div className="mb-8">
            <h3 className="font-bold font-headline text-2xl mb-2" style={{ color: "var(--t-text)" }}>Pro</h3>
            <div className="text-4xl font-bold font-headline" style={{ color: "var(--t-text)" }}>
              {PRICING.pro.price}<span className="text-lg font-normal" style={{ color: "var(--t-text-muted)" }}> one-time</span>
            </div>
          </div>

          <ul className="space-y-4 mb-10 flex-grow">
            {PRICING.pro.features.map((feature, i) => (
              <li key={feature} className={`flex items-center gap-3 text-sm ${i === 0 ? "font-medium" : ""}`} style={{ color: i === 0 ? "var(--t-text)" : "var(--t-text-secondary)" }}>
                <span style={{ color: "var(--t-accent)" }}>&#10003;</span>
                {feature}
              </li>
            ))}
          </ul>

          <a href={SITE.lemonsqueezy} target="_blank" rel="noopener noreferrer">
            <button className="w-full py-4 rounded-lg font-bold font-headline text-lg hover:brightness-110 transition-all" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>
              Upgrade to Pro
            </button>
          </a>
        </div>
      </div>
    </section>
  )
}
