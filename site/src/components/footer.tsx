import { Timer, Download } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { SITE } from "@/lib/constants"

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="pb-12 pt-24 md:pt-32">
      <div className="mx-auto max-w-6xl px-6">
        {/* Final CTA */}
        <div className="text-center mb-16">
          <h2 className="text-2xl font-bold text-white md:text-3xl">
            Stop missing meetings.
          </h2>
          <p className="mt-3 text-zinc-400">
            Download Ticker and never be late again.
          </p>
          <div className="mt-6">
            <a
              href={SITE.downloadUrl}
              target="_blank"
              rel="noopener noreferrer"
            >
              <Button className="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white border-0 h-11 px-8 gap-2 rounded-xl">
                <Download className="size-4" />
                Download Free
              </Button>
            </a>
          </div>
        </div>

        <Separator className="bg-white/10" />

        {/* Bottom bar */}
        <div className="mt-8 flex flex-col items-center gap-6 md:flex-row md:justify-between">
          <div className="flex items-center gap-2 text-zinc-500 text-sm">
            <Timer className="size-4" />
            <span>
              Made by{" "}
              <a
                href={SITE.twitter}
                target="_blank"
                rel="noopener noreferrer"
                className="text-zinc-400 hover:text-white transition-colors"
              >
                Rajdeep
              </a>{" "}
              &middot; {currentYear}
            </span>
          </div>

          <nav
            className="flex items-center gap-6 text-sm text-zinc-500"
            aria-label="Footer navigation"
          >
            <a
              href={SITE.github}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-white transition-colors"
            >
              GitHub
            </a>
            <a
              href={SITE.twitter}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-white transition-colors"
            >
              X / Twitter
            </a>
            <a
              href="/privacy"
              className="hover:text-white transition-colors"
            >
              Privacy
            </a>
            <a
              href="/terms"
              className="hover:text-white transition-colors"
            >
              Terms
            </a>
          </nav>
        </div>
      </div>
    </footer>
  )
}
