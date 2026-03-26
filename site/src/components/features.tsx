export function Features() {
  return (
    <section className="py-32 px-6 overflow-hidden" id="features">
      <div className="max-w-7xl mx-auto">
        {/* Section header */}
        <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6">
          <div className="max-w-xl">
            <h2 className="text-4xl lg:text-5xl font-bold text-white font-headline mb-4 tracking-tight">
              The Pro Workflow.
            </h2>
            <p className="text-zinc-500 text-lg">
              Designed for builders who need a high-density, low-friction way to manage their time.
            </p>
          </div>
          <div className="text-[10px] font-mono text-[#00FF88]/40 text-right uppercase tracking-[0.3em]">
            Feature_Set // v2.4.0 <br /> Standard_Operations_Mode
          </div>
        </div>

        {/* Bento Grid */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-6">
          {/* Large: Event Creation */}
          <div className="md:col-span-8 group relative bg-[#1c1b1d] border border-zinc-800 rounded-2xl overflow-hidden hover:border-[#00FF88]/40 transition-all duration-500">
            <div className="p-8 pb-0 relative z-10">
              <div className="flex items-center gap-3 mb-4">
                <span className="bg-[#00FF88] text-black text-[10px] font-black px-2 py-0.5 rounded tracking-tighter">PRO</span>
                <h3 className="text-2xl font-bold text-white font-headline">Natural Event Creation</h3>
              </div>
              <p className="text-zinc-400 text-sm max-w-md mb-6 leading-relaxed">
                Click anywhere on the timeline to create events. Type &ldquo;Standup at 10am tomorrow&rdquo; and let the NLP engine handle the rest.
              </p>
              <div className="flex gap-4 mb-8">
                <div className="flex items-start gap-2">
                  <span className="text-[#00FF88] text-xs mt-0.5">&#10003;</span>
                  <span className="text-xs text-zinc-500 font-medium leading-tight">NLP parsing built-in</span>
                </div>
                <div className="flex items-start gap-2">
                  <span className="text-[#00FF88] text-xs mt-0.5">&#10003;</span>
                  <span className="text-xs text-zinc-500 font-medium leading-tight">Drag to set duration</span>
                </div>
              </div>
            </div>
            {/* Mockup: NLP input */}
            <div className="px-8 pb-8">
              <div className="relative rounded-xl overflow-hidden border border-zinc-700/50 shadow-2xl bg-[#131315] p-4">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-2 h-2 bg-[#00FF88] rounded-full animate-pulse" />
                  <span className="text-zinc-400 text-sm font-mono">Quick Add</span>
                </div>
                <div className="bg-zinc-900 rounded-lg px-4 py-3 border border-zinc-800 text-sm text-white font-mono">
                  Team standup 3pm 45m
                </div>
                <div className="mt-3 flex gap-2">
                  <span className="bg-blue-500/20 text-blue-400 text-[10px] px-2 py-0.5 rounded">3:00 PM</span>
                  <span className="bg-emerald-500/20 text-emerald-400 text-[10px] px-2 py-0.5 rounded">45 min</span>
                  <span className="bg-zinc-800 text-zinc-400 text-[10px] px-2 py-0.5 rounded">Today</span>
                </div>
              </div>
            </div>
          </div>

          {/* Small: RSVP */}
          <div className="md:col-span-4 group bg-[#1c1b1d] border border-zinc-800 rounded-2xl p-8 flex flex-col hover:border-[#00FF88]/40 transition-all duration-500">
            <div className="mb-8">
              <div className="flex items-center gap-3 mb-4">
                <span className="bg-[#00FF88] text-black text-[10px] font-black px-2 py-0.5 rounded tracking-tighter">PRO</span>
                <h3 className="text-xl font-bold text-white font-headline">Instant RSVP</h3>
              </div>
              <p className="text-zinc-400 text-sm leading-relaxed mb-6">
                Respond to invites in real-time from the menu bar. No context switching needed.
              </p>
            </div>
            {/* Mini RSVP mockup */}
            <div className="flex-grow flex items-center justify-center">
              <div className="bg-[#131315] border border-zinc-800 rounded-xl p-4 shadow-xl w-full transform group-hover:-translate-y-2 transition-transform duration-500">
                <div className="text-white font-bold text-xs mb-1">Planning Sync</div>
                <div className="text-[10px] text-zinc-500 mb-3">2:00 &ndash; 2:30 PM</div>
                <div className="grid grid-cols-3 gap-1 mb-3">
                  <div className="h-1.5 bg-[#00FF88] rounded-full" />
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
          <div className="md:col-span-4 group bg-[#1c1b1d] border border-zinc-800 rounded-2xl p-8 flex flex-col hover:border-[#00FF88]/40 transition-all duration-500 relative overflow-hidden">
            <div className="relative z-10">
              <div className="flex items-center gap-3 mb-4">
                <span className="bg-[#00FF88] text-black text-[10px] font-black px-2 py-0.5 rounded tracking-tighter">PRO</span>
                <h3 className="text-xl font-bold text-white font-headline">Unified Sync</h3>
              </div>
              <p className="text-zinc-400 text-sm leading-relaxed">
                Merge Google and Apple Calendar into one clean, native timeline.
              </p>
            </div>
            <div className="mt-8 flex gap-4 justify-center">
              <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center text-blue-400 text-xl">G</div>
              <div className="w-12 h-12 bg-zinc-700/30 rounded-lg flex items-center justify-center text-zinc-400 text-xl">&#xf8ff;</div>
              <div className="w-12 h-12 bg-emerald-500/10 rounded-lg flex items-center justify-center text-emerald-400 text-xl">&#128197;</div>
            </div>
            <div className="absolute -right-8 -bottom-8 w-32 h-32 bg-[#00FF88]/5 rounded-full blur-3xl group-hover:bg-[#00FF88]/10 transition-colors" />
          </div>

          {/* Large: Precision Drag */}
          <div className="md:col-span-8 group bg-[#1c1b1d] border border-zinc-800 rounded-2xl overflow-hidden hover:border-[#00FF88]/40 transition-all duration-500 flex flex-col md:flex-row">
            <div className="p-8 md:w-1/2 flex flex-col justify-center">
              <div className="flex items-center gap-3 mb-4">
                <span className="bg-[#00FF88] text-black text-[10px] font-black px-2 py-0.5 rounded tracking-tighter">PRO</span>
                <h3 className="text-2xl font-bold text-white font-headline">Precision Drag</h3>
              </div>
              <p className="text-zinc-400 text-sm leading-relaxed mb-6">
                Grab any event and slide it to a new time slot. Resize blocks to adjust duration. Smooth 60fps, snaps to 15-min grid.
              </p>
              <ul className="space-y-2">
                <li className="flex items-center gap-2 text-[11px] text-zinc-500 font-mono">
                  <span className="text-[#00FF88]">$</span> SNAPPING = 15_MIN_GRID
                </li>
                <li className="flex items-center gap-2 text-[11px] text-zinc-500 font-mono">
                  <span className="text-[#00FF88]">$</span> RESIZE + MOVE = SUPPORTED
                </li>
              </ul>
            </div>
            {/* Drag mockup */}
            <div className="md:w-1/2 p-6 relative">
              <div className="bg-zinc-900 border border-zinc-800 rounded-lg p-4 shadow-2xl relative overflow-hidden h-full min-h-[200px]">
                {/* Timeline lines */}
                <div className="space-y-6">
                  <div className="flex items-center gap-3">
                    <span className="text-[10px] text-zinc-600 font-mono w-8">10:00</span>
                    <div className="flex-1 h-[1px] bg-zinc-800" />
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-[10px] text-zinc-600 font-mono w-8">10:30</span>
                    <div className="flex-1 h-[1px] bg-zinc-800" />
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-[10px] text-zinc-600 font-mono w-8">11:00</span>
                    <div className="flex-1 h-[1px] bg-zinc-800" />
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-[10px] text-zinc-600 font-mono w-8">11:30</span>
                    <div className="flex-1 h-[1px] bg-zinc-800" />
                  </div>
                </div>
                {/* Draggable event block */}
                <div className="absolute top-8 left-14 right-4 h-12 bg-[#00FF88]/15 border border-[#00FF88]/40 rounded flex items-center px-3 gap-2 group-hover:top-16 transition-all duration-700">
                  <div className="w-1 h-6 bg-[#00FF88] rounded-full" />
                  <span className="text-[#00FF88] text-xs font-bold">Design Review</span>
                  <div className="ml-auto text-zinc-500 text-[10px]">&#8597;</div>
                </div>
              </div>
            </div>
          </div>

          {/* Full width: Guest Management */}
          <div className="md:col-span-12 group bg-[#1c1b1d] border border-zinc-800 rounded-2xl p-8 hover:border-[#00FF88]/40 transition-all duration-500">
            <div className="flex flex-col md:flex-row gap-8 items-center">
              <div className="md:w-1/2">
                <div className="flex items-center gap-3 mb-4">
                  <span className="bg-[#00FF88] text-black text-[10px] font-black px-2 py-0.5 rounded tracking-tighter">PRO</span>
                  <h3 className="text-2xl font-bold text-white font-headline">Guest Management</h3>
                </div>
                <p className="text-zinc-400 text-sm leading-relaxed">
                  Add attendees with autocomplete from recent contacts. See each guest&apos;s RSVP status at a glance — green for accepted, red for declined, yellow for tentative.
                </p>
              </div>
              <div className="md:w-1/2 flex gap-2 flex-wrap justify-center">
                {["Alex K.", "Sarah M.", "John D.", "Priya R.", "+3 more"].map((name) => (
                  <div key={name} className="flex items-center gap-2 bg-zinc-900 border border-zinc-800 rounded-full px-3 py-1.5">
                    <div className="w-5 h-5 rounded-full bg-zinc-700 flex items-center justify-center text-[9px] text-white font-bold">
                      {name[0]}
                    </div>
                    <span className="text-zinc-400 text-xs">{name}</span>
                    {name !== "+3 more" && (
                      <div className={`w-2 h-2 rounded-full ${name === "Alex K." || name === "Sarah M." ? "bg-emerald-400" : name === "John D." ? "bg-yellow-400" : "bg-zinc-600"}`} />
                    )}
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
