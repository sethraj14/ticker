export function Features() {
  return (
    <section className="py-32 px-6 overflow-hidden" id="features" style={{ background: "var(--t-bg)" }}>
      <div className="max-w-7xl mx-auto">
        <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6">
          <div className="max-w-xl">
            <h2 className="text-4xl lg:text-5xl font-bold font-headline mb-4 tracking-tight" style={{ color: "var(--t-text)" }}>
              The Pro Workflow.
            </h2>
            <p className="text-lg" style={{ color: "var(--t-text-muted)" }}>
              Designed for builders who need a high-density, low-friction way to manage their time.
            </p>
          </div>
          <div className="text-[10px] font-mono text-right uppercase tracking-[0.3em]" style={{ color: "var(--t-accent)", opacity: 0.4 }}>
            Feature_Set // v2.4.0 <br /> Standard_Operations_Mode
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
          {/* Large: Event Creation */}
          <div className="md:col-span-8 group relative rounded-2xl overflow-hidden transition-all duration-500" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
            <div className="p-8 pb-0 relative z-10">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-[10px] font-black px-2 py-0.5 rounded tracking-tighter" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>PRO</span>
                <h3 className="text-2xl font-bold font-headline" style={{ color: "var(--t-text)" }}>Natural Event Creation</h3>
              </div>
              <p className="text-sm max-w-md mb-6 leading-relaxed" style={{ color: "var(--t-text-secondary)" }}>
                Click anywhere on the timeline to create events. Type &ldquo;Standup at 10am tomorrow&rdquo; and let the NLP engine handle the rest.
              </p>
              <div className="flex gap-4 mb-8">
                {["NLP parsing built-in", "Drag to set duration"].map((t) => (
                  <div key={t} className="flex items-start gap-2">
                    <span className="text-xs mt-0.5" style={{ color: "var(--t-accent)" }}>&#10003;</span>
                    <span className="text-xs font-medium leading-tight" style={{ color: "var(--t-text-muted)" }}>{t}</span>
                  </div>
                ))}
              </div>
            </div>
            <div className="px-8 pb-8">
              <div className="relative rounded-xl overflow-hidden border shadow-2xl p-4" style={{ background: "var(--t-popover-bg)", borderColor: "var(--t-border)" }}>
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-2 h-2 rounded-full animate-pulse" style={{ background: "var(--t-accent)" }} />
                  <span className="text-sm font-mono" style={{ color: "var(--t-text-secondary)" }}>Quick Add</span>
                </div>
                <div className="rounded-lg px-4 py-3 border text-sm font-mono text-white" style={{ background: "#18181b", borderColor: "#27272a" }}>
                  Team standup 3pm 45m
                </div>
                <div className="mt-3 flex gap-2">
                  <span className="bg-blue-500/20 text-blue-400 text-[10px] px-2 py-0.5 rounded">3:00 PM</span>
                  <span className="bg-emerald-500/20 text-emerald-400 text-[10px] px-2 py-0.5 rounded">45 min</span>
                  <span className="text-[10px] px-2 py-0.5 rounded" style={{ background: "var(--t-accent-subtle)", color: "var(--t-text-muted)" }}>Today</span>
                </div>
              </div>
            </div>
          </div>

          {/* Small: RSVP */}
          <div className="md:col-span-4 group rounded-2xl p-8 flex flex-col transition-all duration-500" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
            <div className="mb-8">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-[10px] font-black px-2 py-0.5 rounded tracking-tighter" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>PRO</span>
                <h3 className="text-xl font-bold font-headline" style={{ color: "var(--t-text)" }}>Instant RSVP</h3>
              </div>
              <p className="text-sm leading-relaxed mb-6" style={{ color: "var(--t-text-secondary)" }}>
                Respond to invites in real-time from the menu bar. No context switching needed.
              </p>
            </div>
            <div className="flex-grow flex items-center justify-center">
              <div className="rounded-xl p-4 shadow-xl w-full transform group-hover:-translate-y-2 transition-transform duration-500" style={{ background: "var(--t-popover-bg)", border: "1px solid var(--t-border)" }}>
                <div className="text-white font-bold text-xs mb-1">Planning Sync</div>
                <div className="text-[10px] text-zinc-500 mb-3">2:00 &ndash; 2:30 PM</div>
                <div className="grid grid-cols-3 gap-1 mb-3">
                  <div className="h-1.5 rounded-full" style={{ background: "var(--t-accent)" }} />
                  <div className="h-1.5 bg-zinc-800 rounded-full" />
                  <div className="h-1.5 bg-zinc-800 rounded-full" />
                </div>
                <div className="flex justify-between">
                  <button className="px-3 py-1 bg-emerald-950 text-emerald-400 text-[9px] font-bold rounded">Going</button>
                  <button className="px-3 py-1 bg-zinc-800 text-zinc-500 text-[9px] font-bold rounded">Maybe</button>
                  <button className="px-3 py-1 bg-zinc-800 text-zinc-500 text-[9px] font-bold rounded">No</button>
                </div>
              </div>
            </div>
          </div>

          {/* Small: Multi-Account */}
          <div className="md:col-span-4 group rounded-2xl p-8 flex flex-col transition-all duration-500 relative overflow-hidden" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
            <div className="relative z-10">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-[10px] font-black px-2 py-0.5 rounded tracking-tighter" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>PRO</span>
                <h3 className="text-xl font-bold font-headline" style={{ color: "var(--t-text)" }}>Unified Sync</h3>
              </div>
              <p className="text-sm leading-relaxed" style={{ color: "var(--t-text-secondary)" }}>
                Merge Google and Apple Calendar into one clean, native timeline.
              </p>
            </div>
            <div className="mt-8 flex gap-4 justify-center">
              <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center text-blue-400 text-xl font-bold">G</div>
              <div className="w-12 h-12 rounded-lg flex items-center justify-center text-xl" style={{ background: "var(--t-accent-subtle)", color: "var(--t-text-muted)" }}>&#xf8ff;</div>
              <div className="w-12 h-12 bg-emerald-500/10 rounded-lg flex items-center justify-center text-emerald-400 text-xl">&#128197;</div>
            </div>
            <div className="absolute -right-8 -bottom-8 w-32 h-32 rounded-full blur-3xl transition-colors" style={{ background: "var(--t-accent-subtle)" }} />
          </div>

          {/* Large: Precision Drag */}
          <div className="md:col-span-8 group rounded-2xl overflow-hidden transition-all duration-500 flex flex-col md:flex-row" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
            <div className="p-8 md:w-1/2 flex flex-col justify-center">
              <div className="flex items-center gap-3 mb-4">
                <span className="text-[10px] font-black px-2 py-0.5 rounded tracking-tighter" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>PRO</span>
                <h3 className="text-2xl font-bold font-headline" style={{ color: "var(--t-text)" }}>Precision Drag</h3>
              </div>
              <p className="text-sm leading-relaxed mb-6" style={{ color: "var(--t-text-secondary)" }}>
                Grab any event and slide it to a new time slot. Resize blocks to adjust duration. Smooth 60fps, snaps to 15-min grid.
              </p>
              <ul className="space-y-2">
                {["SNAPPING = 15_MIN_GRID", "RESIZE + MOVE = SUPPORTED"].map((cmd) => (
                  <li key={cmd} className="flex items-center gap-2 text-[11px] font-mono" style={{ color: "var(--t-text-muted)" }}>
                    <span style={{ color: "var(--t-accent)" }}>$</span> {cmd}
                  </li>
                ))}
              </ul>
            </div>
            <div className="md:w-1/2 p-6 relative">
              <div className="rounded-lg p-4 shadow-2xl relative overflow-hidden h-full min-h-[200px]" style={{ background: "var(--t-popover-bg)", border: "1px solid var(--t-border)" }}>
                <div className="space-y-6">
                  {["10:00", "10:30", "11:00", "11:30"].map((t) => (
                    <div key={t} className="flex items-center gap-3">
                      <span className="text-[10px] font-mono w-8" style={{ color: "var(--t-text-faint)" }}>{t}</span>
                      <div className="flex-1 h-[1px]" style={{ background: "var(--t-border)" }} />
                    </div>
                  ))}
                </div>
                <div className="absolute top-8 left-14 right-4 h-12 rounded flex items-center px-3 gap-2 group-hover:top-16 transition-all duration-700" style={{ background: "rgba(0, 255, 136, 0.1)", border: "1px solid rgba(0, 255, 136, 0.3)" }}>
                  <div className="w-1 h-6 rounded-full" style={{ background: "var(--t-accent)" }} />
                  <span className="text-xs font-bold" style={{ color: "var(--t-accent)" }}>Design Review</span>
                  <div className="ml-auto text-[10px]" style={{ color: "var(--t-text-muted)" }}>&#8597;</div>
                </div>
              </div>
            </div>
          </div>

          {/* Full width: Guest Management */}
          <div className="md:col-span-12 group rounded-2xl p-8 transition-all duration-500" style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}>
            <div className="flex flex-col md:flex-row gap-8 items-center">
              <div className="md:w-1/2">
                <div className="flex items-center gap-3 mb-4">
                  <span className="text-[10px] font-black px-2 py-0.5 rounded tracking-tighter" style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}>PRO</span>
                  <h3 className="text-2xl font-bold font-headline" style={{ color: "var(--t-text)" }}>Guest Management</h3>
                </div>
                <p className="text-sm leading-relaxed" style={{ color: "var(--t-text-secondary)" }}>
                  Add attendees with autocomplete from recent contacts. See each guest&apos;s RSVP status at a glance.
                </p>
              </div>
              <div className="md:w-1/2 flex gap-2 flex-wrap justify-center">
                {[
                  { name: "Alex K.", color: "bg-emerald-400" },
                  { name: "Sarah M.", color: "bg-emerald-400" },
                  { name: "John D.", color: "bg-yellow-400" },
                  { name: "Priya R.", color: "bg-zinc-600" },
                  { name: "+3 more", color: "" },
                ].map((g) => (
                  <div key={g.name} className="flex items-center gap-2 rounded-full px-3 py-1.5" style={{ background: "var(--t-popover-bg)", border: "1px solid var(--t-border)" }}>
                    <div className="w-5 h-5 rounded-full bg-zinc-700 flex items-center justify-center text-[9px] text-white font-bold">
                      {g.name[0]}
                    </div>
                    <span className="text-xs" style={{ color: "var(--t-text-secondary)" }}>{g.name}</span>
                    {g.color && <div className={`w-2 h-2 rounded-full ${g.color}`} />}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
