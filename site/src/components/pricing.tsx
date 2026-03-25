import { Check, Download, ExternalLink } from "lucide-react"
import { Button } from "@/components/ui/button"
import { SITE, PRICING } from "@/lib/constants"

export function Pricing() {
  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-white md:text-4xl">
            Simple pricing. No surprises.
          </h2>
          <p className="mt-4 text-lg text-zinc-400 max-w-2xl mx-auto">
            Start free. Upgrade once if you want more power. That&apos;s it.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 max-w-4xl mx-auto">
          {/* Free Tier */}
          <div className="rounded-xl border border-white/10 bg-white/[0.03] p-8 flex flex-col">
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-white">
                {PRICING.free.name}
              </h3>
              <div className="mt-3 flex items-baseline gap-1">
                <span className="text-4xl font-bold text-white">
                  {PRICING.free.price}
                </span>
                <span className="text-zinc-500 text-sm">forever</span>
              </div>
              <p className="mt-3 text-sm text-zinc-400">
                {PRICING.free.description}
              </p>
            </div>

            <ul className="flex-1 space-y-3 mb-8">
              {PRICING.free.features.map((feature) => (
                <li key={feature} className="flex items-start gap-3 text-sm">
                  <Check className="size-4 text-zinc-500 mt-0.5 shrink-0" />
                  <span className="text-zinc-300">{feature}</span>
                </li>
              ))}
            </ul>

            <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
              <Button
                variant="outline"
                className="w-full border-white/20 text-white hover:bg-white/10 h-11 rounded-xl gap-2"
              >
                <Download className="size-4" />
                Download Free
              </Button>
            </a>
          </div>

          {/* Pro Tier */}
          <div className="relative rounded-xl p-px bg-gradient-to-b from-purple-600/50 to-blue-600/50">
            <div className="rounded-[11px] bg-[#0c0c0e] p-8 h-full flex flex-col">
              <div className="mb-6">
                <div className="flex items-center gap-2">
                  <h3 className="text-lg font-semibold text-white">
                    {PRICING.pro.name}
                  </h3>
                  <span className="inline-flex items-center rounded-full bg-gradient-to-r from-purple-600 to-blue-600 px-2.5 py-0.5 text-[10px] font-medium text-white">
                    Popular
                  </span>
                </div>
                <div className="mt-3 flex items-baseline gap-1">
                  <span className="text-4xl font-bold text-white">
                    {PRICING.pro.price}
                  </span>
                  <span className="text-zinc-500 text-sm">one-time</span>
                </div>
                <p className="mt-2 text-xs text-purple-400">
                  {PRICING.pro.priceNote}
                </p>
                <p className="mt-2 text-sm text-zinc-400">
                  {PRICING.pro.description}
                </p>
              </div>

              <ul className="flex-1 space-y-3 mb-8">
                {PRICING.pro.features.map((feature) => (
                  <li key={feature} className="flex items-start gap-3 text-sm">
                    <Check className="size-4 text-purple-400 mt-0.5 shrink-0" />
                    <span className="text-zinc-300">{feature}</span>
                  </li>
                ))}
              </ul>

              <a
                href={SITE.lemonsqueezy}
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button className="w-full bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white border-0 h-11 rounded-xl gap-2">
                  <ExternalLink className="size-4" />
                  Get Pro — {PRICING.pro.price}
                </Button>
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
