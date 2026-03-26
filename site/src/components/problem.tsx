export function Problem() {
  return (
    <section className="py-24 px-6" style={{ background: "var(--t-bg-subtle)", borderTop: "1px solid var(--t-border)", borderBottom: "1px solid var(--t-border)" }}>
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-20 max-w-2xl mx-auto">
          <h2 className="text-3xl lg:text-4xl font-bold font-headline mb-4" style={{ color: "var(--t-text)" }}>
            You missed a meeting because you were deep in code.
          </h2>
          <p style={{ color: "var(--t-text-muted)" }}>
            The friction of context switching kills your flow. Ticker keeps you aware without the noise.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {[
            { icon: "\u{1F6E1}", title: "Context Protection", desc: "Stay in your IDE while keeping a persistent, non-intrusive eye on your schedule." },
            { icon: "\u26A1", title: "Instant RSVP", desc: "Accept or decline invites directly from the menu bar without ever loading a browser tab." },
            { icon: "\u23F1", title: "Time Awareness", desc: "A live countdown tells you exactly how much deep-work time you have left before standup." },
          ].map((item) => (
            <div
              key={item.title}
              className="p-8 rounded-xl transition-colors group"
              style={{ background: "var(--t-bg-card)", border: "1px solid var(--t-border)" }}
              onMouseEnter={(e) => e.currentTarget.style.borderColor = "var(--t-border-hover)"}
              onMouseLeave={(e) => e.currentTarget.style.borderColor = "var(--t-border)"}
            >
              <div className="mb-6 text-3xl group-hover:scale-110 transition-transform inline-block" style={{ color: "var(--t-accent)" }}>
                {item.icon}
              </div>
              <h3 className="font-bold font-headline text-xl mb-3" style={{ color: "var(--t-text)" }}>
                {item.title}
              </h3>
              <p className="leading-relaxed" style={{ color: "var(--t-text-secondary)" }}>
                {item.desc}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
