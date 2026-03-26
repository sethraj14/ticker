import { Navbar } from "@/components/navbar"
import { Hero } from "@/components/hero"
import { Problem } from "@/components/problem"
import { Features } from "@/components/features"
import { Pricing } from "@/components/pricing"
import { Faq } from "@/components/faq"
import { Footer } from "@/components/footer"

export const revalidate = 3600

interface PageProps {
  searchParams: Promise<Record<string, string | string[] | undefined>>
}

export default async function Home({ searchParams }: PageProps) {
  const params = await searchParams
  const isProductHunt = params.ref === "producthunt"

  return (
    <>
      {/* Animated grid background */}
      <div className="fixed inset-0 -z-10 opacity-50" style={{
        backgroundImage: "linear-gradient(to right, #18181b 1px, transparent 1px), linear-gradient(to bottom, #18181b 1px, transparent 1px)",
        backgroundSize: "40px 40px",
      }} />

      <Navbar />
      <main>
        <Hero isProductHunt={isProductHunt} />
        <Problem />
        <Features />
        <Pricing />
        <Faq />
      </main>
      <Footer />
    </>
  )
}
