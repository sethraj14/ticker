"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Mail } from "lucide-react"

export function EmailCapture() {
  const [email, setEmail] = useState("")
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) return
    // TODO: Connect to Lemon Squeezy email list or similar
    setSubmitted(true)
  }

  if (submitted) {
    return (
      <div className="text-center py-3">
        <p className="text-green-400 font-medium">You&apos;re on the list!</p>
        <p className="text-zinc-500 text-sm mt-1">
          We&apos;ll notify you when we launch.
        </p>
      </div>
    )
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto"
    >
      <input
        type="email"
        required
        placeholder="you@email.com"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="flex-1 h-11 rounded-lg bg-white/5 border border-white/10 px-4 text-white placeholder:text-zinc-500 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-purple-500/50"
        aria-label="Email address for launch notification"
      />
      <Button
        type="submit"
        className="bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-500 hover:to-blue-500 text-white border-0 h-11 px-6 rounded-lg gap-2"
      >
        <Mail className="size-4" />
        Notify Me
      </Button>
    </form>
  )
}
