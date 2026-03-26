import { Download, ExternalLink, Apple, Code, Gift } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { SITE, PRICING } from "@/lib/constants"
import { EmailCapture } from "@/components/email-capture"

interface HeroProps {
  isProductHunt?: boolean
}

export function Hero({ isProductHunt = false }: HeroProps) {
  const heading = isProductHunt
    ? "The menu bar calendar developers love"
    : SITE.tagline

  return (
    <section className="relative pt-32 pb-24 md:pt-44 md:pb-32 overflow-hidden">
      {/* Background gradient orbs */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[600px] opacity-30 pointer-events-none">
        <div className="absolute top-20 left-1/4 w-72 h-72 rounded-full bg-purple-600/40 blur-[120px]" />
        <div className="absolute top-40 right-1/4 w-72 h-72 rounded-full bg-blue-600/30 blur-[120px]" />
      </div>

      <div className="relative mx-auto max-w-6xl px-6 text-center">
        {isProductHunt && (
          <div className="mb-8 inline-flex items-center gap-2 rounded-full border border-orange-500/30 bg-orange-500/10 px-4 py-2 text-sm text-orange-300">
            <span className="font-medium">Featured on Product Hunt</span>
          </div>
        )}

        <h1 className="text-4xl font-bold tracking-tight text-white md:text-6xl lg:text-7xl max-w-4xl mx-auto leading-[1.1]">
          {heading}
        </h1>

        <p className="mt-6 text-lg text-zinc-400 md:text-xl max-w-2xl mx-auto leading-relaxed">
          A beautiful menu bar calendar for macOS. Live countdown, one-click join, and full event management — create, drag, RSVP, all without leaving your workflow.
        </p>

        <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
          <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer" aria-label="Download Ticker for free">
            <Button className="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white border-0 h-12 px-8 text-base gap-2 rounded-xl min-w-[200px]">
              <Download className="size-5" />
              Download Free
            </Button>
          </a>
          <a href={SITE.lemonsqueezy} target="_blank" rel="noopener noreferrer" aria-label={`Get Ticker Pro for ${PRICING.pro.price}`}>
            <Button
              variant="outline"
              className="border-white/20 text-white hover:bg-white/10 h-12 px-8 text-base gap-2 rounded-xl min-w-[200px]"
            >
              <ExternalLink className="size-4" />
              Get Pro — {PRICING.pro.price}
            </Button>
          </a>
        </div>

        {/* Badges */}
        <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
          <Badge
            variant="outline"
            className="border-white/15 text-zinc-300 bg-white/5 gap-1.5 px-3 py-1 h-auto"
          >
            <Apple className="size-3" />
            macOS 13+
          </Badge>
          <Badge
            variant="outline"
            className="border-white/15 text-zinc-300 bg-white/5 gap-1.5 px-3 py-1 h-auto"
          >
            <Code className="size-3" />
            Native Swift
          </Badge>
          <Badge
            variant="outline"
            className="border-white/15 text-zinc-300 bg-white/5 gap-1.5 px-3 py-1 h-auto"
          >
            <Gift className="size-3" />
            Free Forever
          </Badge>
        </div>

        {/* Email capture */}
        <div className="mt-10">
          <p className="text-xs text-zinc-600 mb-3">
            Get notified when we launch on Product Hunt
          </p>
          <EmailCapture />
        </div>

        {/* Screenshot placeholder */}
        <div className="mt-16 mx-auto max-w-4xl">
          <div className="relative rounded-2xl border border-white/10 bg-white/5 backdrop-blur-sm overflow-hidden">
            {/* macOS title bar */}
            <div className="flex items-center gap-2 px-4 py-3 border-b border-white/10 bg-white/5">
              <div className="size-3 rounded-full bg-[#ff5f57]" />
              <div className="size-3 rounded-full bg-[#febc2e]" />
              <div className="size-3 rounded-full bg-[#28c840]" />
              <span className="ml-2 text-xs text-zinc-500">Ticker</span>
            </div>
            <div className="flex items-center justify-center h-64 md:h-96 text-zinc-600">
              <p className="text-sm">Screenshot placeholder</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
