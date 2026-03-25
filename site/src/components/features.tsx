import {
  Timer,
  Video,
  Calendar,
  Users,
  Bell,
  Repeat,
  type LucideIcon,
} from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { FEATURES } from "@/lib/constants"

const iconMap: Record<string, LucideIcon> = {
  Timer,
  Video,
  Calendar,
  Users,
  Bell,
  Repeat,
}

export function Features() {
  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-white md:text-4xl">
            Everything you need, nothing you don&apos;t
          </h2>
          <p className="mt-4 text-lg text-zinc-400 max-w-2xl mx-auto">
            Ticker does one thing and does it well. A menu bar calendar that
            keeps you on time.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((feature) => {
            const Icon = iconMap[feature.icon]
            return (
              <div
                key={feature.title}
                className="group relative rounded-xl border border-white/10 bg-white/[0.03] p-6 transition-all hover:border-white/20 hover:bg-white/[0.06]"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex size-10 items-center justify-center rounded-lg bg-gradient-to-br from-purple-600/20 to-blue-600/20 border border-purple-500/20">
                    {Icon && (
                      <Icon className="size-5 text-purple-400" />
                    )}
                  </div>
                  {feature.isPro && (
                    <Badge className="bg-gradient-to-r from-purple-600 to-blue-600 text-white border-0 text-[10px] px-2">
                      Pro
                    </Badge>
                  )}
                </div>
                <h3 className="text-base font-semibold text-white mb-2">
                  {feature.title}
                </h3>
                <p className="text-sm text-zinc-400 leading-relaxed">
                  {feature.description}
                </p>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
