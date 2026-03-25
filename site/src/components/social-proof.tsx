import { Star, Quote } from "lucide-react"
import { SITE } from "@/lib/constants"
import { GitHubIcon } from "@/components/icons"

export function SocialProof() {
  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-6">
        <div className="text-center mb-16">
          <p className="text-lg text-zinc-400 italic">
            Built by an indie developer who was tired of missing meetings.
          </p>
        </div>

        {/* GitHub stars */}
        <div className="flex justify-center mb-16">
          <a
            href={SITE.github}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-3 rounded-full border border-white/10 bg-white/[0.03] px-6 py-3 transition-all hover:border-white/20 hover:bg-white/[0.06]"
          >
            <GitHubIcon className="size-5 text-white" />
            <span className="text-sm text-zinc-300">Star on GitHub</span>
            <span className="flex items-center gap-1 rounded-full bg-white/10 px-2.5 py-0.5 text-xs text-zinc-300">
              <Star className="size-3 fill-yellow-400 text-yellow-400" />
              <span>--</span>
            </span>
          </a>
        </div>

        {/* Testimonial placeholders */}
        <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="rounded-xl border border-white/10 border-dashed bg-white/[0.02] p-6 flex flex-col items-center justify-center min-h-[180px] text-center"
            >
              <Quote className="size-8 text-zinc-700 mb-3" />
              <p className="text-sm text-zinc-600">Testimonial coming soon</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
