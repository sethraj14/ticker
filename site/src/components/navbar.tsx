"use client"

import { useEffect, useState } from "react"
import { Timer, Download } from "lucide-react"
import { cn } from "@/lib/utils"
import { SITE } from "@/lib/constants"
import { Button } from "@/components/ui/button"
import { GitHubIcon } from "@/components/icons"

export function Navbar() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    function handleScroll() {
      setScrolled(window.scrollY > 20)
    }
    window.addEventListener("scroll", handleScroll, { passive: true })
    return () => window.removeEventListener("scroll", handleScroll)
  }, [])

  return (
    <nav
      className={cn(
        "fixed top-0 left-0 right-0 z-50 transition-all duration-300",
        scrolled
          ? "bg-[#09090b]/80 backdrop-blur-xl border-b border-white/10"
          : "bg-transparent"
      )}
    >
      <div className="mx-auto max-w-6xl px-6 flex items-center justify-between h-16">
        <a
          href="/"
          className="flex items-center gap-2 text-white font-semibold text-lg"
          aria-label={`${SITE.name} home`}
        >
          <Timer className="size-5 text-purple-400" />
          {SITE.name}
        </a>

        <div className="flex items-center gap-3">
          <a
            href={SITE.github}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="View source on GitHub"
          >
            <Button variant="ghost" size="icon" className="text-zinc-400 hover:text-white">
              <GitHubIcon className="size-5" />
            </Button>
          </a>
          <a href={SITE.downloadUrl} target="_blank" rel="noopener noreferrer">
            <Button className="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white border-0 gap-2 h-9 px-4">
              <Download className="size-4" />
              Download
            </Button>
          </a>
        </div>
      </div>
    </nav>
  )
}
