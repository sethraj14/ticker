import { SITE } from "@/lib/constants"

export function Footer() {
  return (
    <footer className="w-full relative z-10" style={{ background: "var(--t-bg-card)", borderTop: "1px solid var(--t-border)" }}>
      <div className="flex flex-col md:flex-row justify-between items-center px-8 py-12 max-w-7xl mx-auto w-full gap-8">
        <div className="text-lg font-bold font-headline" style={{ color: "var(--t-text)" }}>Ticker</div>
        <div className="flex gap-8">
          {[
            { label: "Privacy", href: "/privacy" },
            { label: "Terms", href: "/terms" },
            { label: "GitHub", href: SITE.github, external: true },
          ].map((link) => (
            <a
              key={link.label}
              className="font-bold font-headline text-sm transition-colors"
              href={link.href}
              target={link.external ? "_blank" : undefined}
              rel={link.external ? "noopener noreferrer" : undefined}
              style={{ color: "var(--t-text-muted)" }}
            >
              {link.label}
            </a>
          ))}
        </div>
        <div className="font-bold font-headline text-xs tracking-widest uppercase" style={{ color: "var(--t-text-faint)" }}>
          Made by{" "}
          <a href={SITE.twitter} target="_blank" rel="noopener noreferrer" className="hover:opacity-80 transition-opacity">
            Rajdeep
          </a>
        </div>
      </div>
    </footer>
  )
}
