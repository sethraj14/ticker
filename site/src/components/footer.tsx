import { SITE } from "@/lib/constants"

export function Footer() {
  return (
    <footer className="bg-zinc-950 border-t border-zinc-900 w-full relative z-10">
      <div className="flex flex-col md:flex-row justify-between items-center px-8 py-12 max-w-7xl mx-auto w-full gap-8">
        <div className="text-lg font-bold text-white font-headline">Ticker</div>
        <div className="flex gap-8">
          <a className="text-zinc-500 font-bold font-headline text-sm hover:text-white transition-colors" href="/privacy">
            Privacy
          </a>
          <a className="text-zinc-500 font-bold font-headline text-sm hover:text-white transition-colors" href="/terms">
            Terms
          </a>
          <a className="text-zinc-500 font-bold font-headline text-sm hover:text-white transition-colors" href={SITE.github} target="_blank" rel="noopener noreferrer">
            GitHub
          </a>
        </div>
        <div className="text-zinc-600 font-bold font-headline text-xs tracking-widest uppercase">
          Made by{" "}
          <a href={SITE.twitter} target="_blank" rel="noopener noreferrer" className="hover:text-zinc-400 transition-colors">
            Rajdeep
          </a>
        </div>
      </div>
    </footer>
  )
}
