export function Problem() {
  return (
    <section className="py-24 px-6 border-y border-zinc-900/50 bg-zinc-950/20">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-20 max-w-2xl mx-auto">
          <h2 className="text-3xl lg:text-4xl font-bold text-white font-headline mb-4">
            You missed a meeting because you were deep in code.
          </h2>
          <p className="text-zinc-500">
            The friction of context switching kills your flow. Ticker keeps you aware without the noise.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="bg-[#1c1b1d] border border-zinc-800 p-8 rounded-xl hover:border-[#00FF88]/30 transition-colors group">
            <div className="text-[#00FF88] mb-6 text-3xl group-hover:scale-110 transition-transform inline-block">&#128737;</div>
            <h3 className="text-white font-bold font-headline text-xl mb-3">Context Protection</h3>
            <p className="text-zinc-400 leading-relaxed">
              Stay in your IDE while keeping a persistent, non-intrusive eye on your schedule.
            </p>
          </div>

          <div className="bg-[#1c1b1d] border border-zinc-800 p-8 rounded-xl hover:border-[#00FF88]/30 transition-colors group">
            <div className="text-[#00FF88] mb-6 text-3xl group-hover:scale-110 transition-transform inline-block">&#9889;</div>
            <h3 className="text-white font-bold font-headline text-xl mb-3">Instant RSVP</h3>
            <p className="text-zinc-400 leading-relaxed">
              Accept or decline invites directly from the menu bar without ever loading a browser tab.
            </p>
          </div>

          <div className="bg-[#1c1b1d] border border-zinc-800 p-8 rounded-xl hover:border-[#00FF88]/30 transition-colors group">
            <div className="text-[#00FF88] mb-6 text-3xl group-hover:scale-110 transition-transform inline-block">&#9201;</div>
            <h3 className="text-white font-bold font-headline text-xl mb-3">Time Awareness</h3>
            <p className="text-zinc-400 leading-relaxed">
              A live countdown tells you exactly how much deep-work time you have left before standup.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
