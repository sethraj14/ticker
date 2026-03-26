import { SITE } from "@/lib/constants"
import { ThemeToggle } from "@/components/theme-toggle"

export function Navbar() {
  return (
    <nav className="sticky top-0 w-full z-50 backdrop-blur-md border-b" style={{ background: "var(--t-nav-bg)", borderColor: "var(--t-nav-border)" }}>
      <div className="flex justify-between items-center px-6 py-4 max-w-7xl mx-auto">
        <a href="/" className="text-xl font-bold font-headline tracking-tight" style={{ color: "var(--t-text)" }}>
          Ticker
        </a>
        <div className="hidden md:flex gap-8 items-center">
          {["Features", "Pricing", "FAQ"].map((item) => (
            <a
              key={item}
              className="font-bold font-headline tracking-tight text-sm transition-colors"
              href={`#${item.toLowerCase()}`}
              style={{ color: "var(--t-text-secondary)" }}
              onMouseEnter={(e) => e.currentTarget.style.color = "var(--t-accent)"}
              onMouseLeave={(e) => e.currentTarget.style.color = "var(--t-text-secondary)"}
            >
              {item}
            </a>
          ))}
        </div>
        <div className="flex items-center gap-3">
          <ThemeToggle />
          <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
            <button
              className="px-5 py-2 rounded-lg font-bold font-headline text-sm hover:brightness-110 transition-all"
              style={{ background: "var(--t-accent-bg)", color: "var(--t-accent-text)" }}
            >
              Download Free
            </button>
          </a>
        </div>
      </div>
    </nav>
  )
}
