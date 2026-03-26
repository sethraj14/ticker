import { SITE } from "@/lib/constants"

export function Navbar() {
  return (
    <nav className="sticky top-0 w-full z-50 bg-zinc-950/80 backdrop-blur-md border-b border-zinc-800/50">
      <div className="flex justify-between items-center px-6 py-4 max-w-7xl mx-auto">
        <a href="/" className="text-xl font-bold text-white font-headline tracking-tight">
          Ticker
        </a>
        <div className="hidden md:flex gap-8 items-center">
          <a className="text-zinc-400 font-bold font-headline tracking-tight hover:text-[#00FF88] transition-colors text-sm" href="#features">
            Features
          </a>
          <a className="text-zinc-400 font-bold font-headline tracking-tight hover:text-[#00FF88] transition-colors text-sm" href="#pricing">
            Pricing
          </a>
          <a className="text-zinc-400 font-bold font-headline tracking-tight hover:text-[#00FF88] transition-colors text-sm" href="#faq">
            FAQ
          </a>
        </div>
        <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
          <button className="bg-[#00FF88] text-black px-5 py-2 rounded-lg font-bold font-headline text-sm hover:brightness-110 transition-all">
            Download Free
          </button>
        </a>
      </div>
    </nav>
  )
}
