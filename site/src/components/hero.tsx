import { SITE, PRICING } from "@/lib/constants"

interface HeroProps {
  isProductHunt?: boolean
}

export function Hero({ isProductHunt = false }: HeroProps) {
  const heading = isProductHunt
    ? "The menu bar calendar developers love"
    : null

  return (
    <section className="relative overflow-hidden pt-20 pb-32 px-6">
      <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
        {/* Hero Left */}
        <div>
          {isProductHunt && (
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-orange-500/30 bg-orange-500/10 px-4 py-2 text-sm text-orange-300">
              <span className="font-medium">Featured on Product Hunt</span>
            </div>
          )}

          <span className="text-[#00FF88] font-bold uppercase tracking-[0.2em] text-[10px] mb-4 block">
            macOS menu bar calendar
          </span>

          <h1 className="text-5xl lg:text-[72px] leading-[1.05] font-bold text-white font-headline tracking-tighter mb-8">
            {heading || (<>Your next<br />meeting.<br /><span className="text-zinc-500">Always in sight.</span></>)}
          </h1>

          <p className="text-zinc-400 text-lg max-w-lg mb-10 leading-relaxed">
            Live countdown in your menu bar. One-click join. Create events, drag to reschedule, RSVP — all without opening a browser.
          </p>

          <div className="flex flex-wrap gap-4 mb-12">
            <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
              <button className="bg-[#00FF88] text-black px-8 py-4 rounded-lg font-bold font-headline text-lg hover:brightness-110 transition-all">
                Download Free
              </button>
            </a>
            <a href={SITE.lemonsqueezy} target="_blank" rel="noopener noreferrer">
              <button className="bg-zinc-900 text-white border border-zinc-800 px-8 py-4 rounded-lg font-bold font-headline text-lg hover:bg-zinc-800 transition-all">
                Get Pro — {PRICING.pro.price}
              </button>
            </a>
          </div>

          <div className="flex gap-8 border-t border-zinc-900 pt-8">
            <div className="flex items-center gap-2">
              <span className="text-zinc-600 text-sm">&#xf8ff;</span>
              <span className="text-zinc-500 text-xs font-bold tracking-widest uppercase">macOS 13+</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-zinc-600 text-sm">&lt;/&gt;</span>
              <span className="text-zinc-500 text-xs font-bold tracking-widest uppercase">Native Swift</span>
            </div>
            <div className="flex items-center gap-2">
              <span className="text-[#00FF88] text-sm">$</span>
              <span className="text-zinc-500 text-xs font-bold tracking-widest uppercase">{PRICING.pro.price} one-time</span>
            </div>
          </div>
        </div>

        {/* Hero Right — App Mockup */}
        <div className="relative">
          {/* macOS Menu Bar */}
          <div className="bg-zinc-950/40 backdrop-blur-xl border border-white/10 rounded-t-xl px-4 py-2 flex items-center justify-end gap-4 shadow-2xl">
            <div className="flex items-center gap-2 bg-[#00FF88]/10 border border-[#00FF88]/20 px-2 py-0.5 rounded text-[#00FF88] text-[11px] font-bold">
              <span className="w-1.5 h-1.5 bg-[#00FF88] rounded-full animate-pulse" />
              Standup &middot; 12:34
            </div>
            <span className="text-zinc-400 text-xs">Wi-Fi</span>
            <span className="text-zinc-400 text-xs">100%</span>
            <span className="text-zinc-400 text-xs font-medium">Tue Mar 26</span>
          </div>

          {/* Ticker Popover */}
          <div className="bg-[#131315] border border-zinc-800 rounded-b-xl rounded-tl-xl p-4 shadow-2xl relative z-10" style={{ boxShadow: "0 20px 50px -12px rgba(0, 255, 136, 0.15)" }}>
            {/* Header */}
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-white font-bold font-headline text-sm">Today Mar 26</h3>
              <div className="flex gap-2 text-zinc-500 text-xs">
                <span>+</span>
                <span>&#9881;</span>
              </div>
            </div>

            {/* All-day event */}
            <div className="bg-[#2a2a2c] rounded-lg p-3 mb-4 flex items-center justify-between border border-zinc-700/50">
              <div className="flex items-center gap-3">
                <div className="w-1 h-8 bg-amber-400 rounded-full" />
                <div>
                  <div className="text-xs font-bold text-white">Team Offsite</div>
                  <div className="text-[10px] text-zinc-500">9:00 AM &ndash; 1:00 PM</div>
                </div>
              </div>
            </div>

            {/* Timeline */}
            <div className="space-y-4 relative pl-8 border-l border-zinc-800/50">
              {/* Now line */}
              <div className="absolute top-[35%] left-0 right-0 h-[1px] bg-red-500 z-20 flex items-center">
                <div className="w-1.5 h-1.5 bg-red-500 rounded-full -ml-1" />
              </div>

              <div className="relative">
                <span className="absolute -left-10 top-0 text-[10px] text-zinc-600 font-mono">9:00</span>
                <div className="bg-blue-600/20 border border-blue-500/30 rounded px-3 py-2">
                  <div className="text-xs font-bold text-blue-400">Daily Standup</div>
                </div>
              </div>

              <div className="relative">
                <span className="absolute -left-10 top-0 text-[10px] text-zinc-600 font-mono">10:00</span>
                <div className="bg-emerald-600/20 border border-emerald-500/30 rounded px-3 py-4">
                  <div className="text-xs font-bold text-emerald-400">Design Review</div>
                </div>
              </div>

              <div className="relative">
                <span className="absolute -left-10 top-0 text-[10px] text-zinc-600 font-mono">12:30</span>
                <div className="bg-orange-600/20 border border-orange-500/30 rounded px-3 py-2">
                  <div className="text-xs font-bold text-orange-400">1:1 Sarah</div>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div className="mt-6 pt-4 border-t border-zinc-800 flex items-center justify-between">
              <div>
                <div className="text-[9px] text-zinc-500 uppercase tracking-widest font-bold">Up Next</div>
                <div className="text-xs text-white font-medium">Design Review</div>
              </div>
              <button className="bg-[#00FF88] text-black px-3 py-1.5 rounded-md text-[11px] font-bold flex items-center gap-1">
                Join
              </button>
            </div>
          </div>

          {/* Green glow beneath */}
          <div className="absolute -bottom-10 left-1/2 -translate-x-1/2 w-2/3 h-20 bg-[#00FF88]/10 blur-[80px] -z-10" />
        </div>
      </div>
    </section>
  )
}
