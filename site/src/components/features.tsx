import {
  Timer,
  Video,
  Calendar,
  Plus,
  Move,
  CheckCircle,
  Users,
  Layers,
  Bell,
  type LucideIcon,
} from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { FEATURES } from "@/lib/constants"

const iconMap: Record<string, LucideIcon> = {
  Timer,
  Video,
  Calendar,
  Plus,
  Move,
  CheckCircle,
  Users,
  Layers,
  Bell,
}

export function Features() {
  const freeFeatures = FEATURES.filter((f) => !f.isPro)
  const proFeatures = FEATURES.filter((f) => f.isPro)

  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-6xl px-6">
        <div className="text-center mb-16">
          <h2 className="text-3xl font-bold text-white md:text-4xl">
            A full calendar in your menu bar
          </h2>
          <p className="mt-4 text-lg text-zinc-400 max-w-2xl mx-auto">
            View your day for free. Manage your calendar with Pro.
          </p>
        </div>

        {/* Free features */}
        <div className="mb-6">
          <h3 className="text-sm font-medium text-zinc-500 uppercase tracking-wider mb-6 text-center">
            Free — always
          </h3>
          <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
            {freeFeatures.map((feature) => {
              const Icon = iconMap[feature.icon]
              return (
                <div
                  key={feature.title}
                  className="group relative rounded-xl border border-white/10 bg-white/[0.03] p-6 transition-all hover:border-white/20 hover:bg-white/[0.06]"
                >
                  <div className="mb-4">
                    <div className="flex size-10 items-center justify-center rounded-lg bg-gradient-to-br from-zinc-700/50 to-zinc-800/50 border border-white/10">
                      {Icon && <Icon className="size-5 text-zinc-300" />}
                    </div>
                  </div>
                  <h4 className="text-base font-semibold text-white mb-2">
                    {feature.title}
                  </h4>
                  <p className="text-sm text-zinc-400 leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              )
            })}
          </div>
        </div>

        {/* Divider */}
        <div className="relative my-16">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-white/10" />
          </div>
          <div className="relative flex justify-center">
            <span className="bg-[#0a0a0b] px-4 text-sm text-zinc-500">
              Upgrade to Pro for full control
            </span>
          </div>
        </div>

        {/* Pro features */}
        <div>
          <h3 className="text-sm font-medium uppercase tracking-wider mb-6 text-center">
            <span className="bg-gradient-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent">
              Pro — $7.99 one-time
            </span>
          </h3>
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
            {proFeatures.map((feature) => {
              const Icon = iconMap[feature.icon]
              return (
                <div
                  key={feature.title}
                  className="group relative rounded-xl border border-purple-500/15 bg-purple-500/[0.03] p-6 transition-all hover:border-purple-500/30 hover:bg-purple-500/[0.06]"
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex size-10 items-center justify-center rounded-lg bg-gradient-to-br from-purple-600/20 to-blue-600/20 border border-purple-500/20">
                      {Icon && <Icon className="size-5 text-purple-400" />}
                    </div>
                    <Badge className="bg-gradient-to-r from-purple-600 to-blue-600 text-white border-0 text-[10px] px-2">
                      Pro
                    </Badge>
                  </div>
                  <h4 className="text-base font-semibold text-white mb-2">
                    {feature.title}
                  </h4>
                  <p className="text-sm text-zinc-400 leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              )
            })}
          </div>
        </div>
      </div>
    </section>
  )
}
