export function Demo() {
  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-6">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold text-white md:text-4xl">
            See it in action
          </h2>
          <p className="mt-4 text-lg text-zinc-400">
            A 30-second look at how Ticker keeps you on time.
          </p>
        </div>

        <div className="mx-auto max-w-3xl">
          <div className="relative rounded-2xl border border-white/10 bg-white/[0.03] overflow-hidden">
            {/* macOS window chrome */}
            <div className="flex items-center gap-2 px-4 py-3 border-b border-white/10 bg-white/5">
              <div className="size-3 rounded-full bg-[#ff5f57]" />
              <div className="size-3 rounded-full bg-[#febc2e]" />
              <div className="size-3 rounded-full bg-[#28c840]" />
              <span className="ml-2 text-xs text-zinc-500">
                Ticker Demo
              </span>
            </div>
            <div className="flex items-center justify-center h-64 md:h-80">
              <p className="text-sm text-zinc-600">Demo coming soon</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
