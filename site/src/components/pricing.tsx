import { SITE, PRICING } from "@/lib/constants"

export function Pricing() {
  return (
    <section className="py-32 px-6" id="pricing">
      <div className="max-w-5xl mx-auto text-center mb-16">
        <h2 className="text-4xl font-bold text-white font-headline mb-4">
          Simple, honest pricing.
        </h2>
        <p className="text-zinc-500">Pay once, own it forever. No subscriptions, ever.</p>
      </div>

      <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Free */}
        <div className="bg-[#131315] border border-zinc-800 p-10 rounded-xl flex flex-col">
          <div className="mb-8">
            <h3 className="text-white font-bold font-headline text-2xl mb-2">Free</h3>
            <div className="text-4xl font-bold text-white font-headline">
              $0<span className="text-lg text-zinc-500 font-normal"> forever</span>
            </div>
          </div>

          <ul className="space-y-4 mb-10 flex-grow">
            {PRICING.free.features.map((feature) => (
              <li key={feature} className="flex items-center gap-3 text-zinc-400 text-sm">
                <span className="text-[#00FF88] text-sm">&#10003;</span>
                {feature}
              </li>
            ))}
          </ul>

          <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
            <button className="w-full py-4 border border-zinc-800 rounded-lg font-bold font-headline text-white hover:bg-zinc-900 transition-all">
              Download Now
            </button>
          </a>
        </div>

        {/* Pro */}
        <div className="bg-[#131315] border-2 border-[#00FF88] p-10 rounded-xl flex flex-col relative">
          <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-[#00FF88] text-black px-4 py-1 rounded-full text-xs font-bold uppercase tracking-wider">
            Most Popular
          </div>

          <div className="mb-8">
            <h3 className="text-white font-bold font-headline text-2xl mb-2">Pro</h3>
            <div className="text-4xl font-bold text-white font-headline">
              {PRICING.pro.price}<span className="text-lg text-zinc-500 font-normal"> one-time</span>
            </div>
          </div>

          <ul className="space-y-4 mb-10 flex-grow">
            {PRICING.pro.features.map((feature, i) => (
              <li key={feature} className={`flex items-center gap-3 text-sm ${i === 0 ? "text-white font-medium" : "text-zinc-400"}`}>
                <span className="text-[#00FF88] text-sm">&#10003;</span>
                {feature}
              </li>
            ))}
          </ul>

          <a href={SITE.lemonsqueezy} target="_blank" rel="noopener noreferrer">
            <button className="w-full py-4 bg-[#00FF88] text-black rounded-lg font-bold font-headline text-lg hover:brightness-110 transition-all">
              Upgrade to Pro
            </button>
          </a>
        </div>
      </div>
    </section>
  )
}
