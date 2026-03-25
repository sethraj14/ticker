import { Navbar } from "@/components/navbar"
import { Hero } from "@/components/hero"
import { Problem } from "@/components/problem"
import { Features } from "@/components/features"
import { Pricing } from "@/components/pricing"
import { SocialProof } from "@/components/social-proof"
import { Demo } from "@/components/demo"
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
      <Navbar />
      <main>
        <Hero isProductHunt={isProductHunt} />
        <Problem />
        <Features />
        <Pricing />
        <SocialProof />
        <Demo />
        <Faq />
      </main>
      <Footer />
    </>
  )
}
