"use client"

import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "@/components/ui/accordion"
import { FAQ } from "@/lib/constants"

export function Faq() {
  return (
    <section className="py-24 md:py-32">
      <div className="mx-auto max-w-3xl px-6">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold text-white md:text-4xl">
            Frequently asked questions
          </h2>
        </div>

        <Accordion className="space-y-2">
          {FAQ.map((item, index) => (
            <AccordionItem
              key={index}
              value={index}
              className="rounded-lg border border-white/10 bg-white/[0.03] px-4"
            >
              <AccordionTrigger className="text-white hover:no-underline py-4 text-left text-base font-medium">
                {item.q}
              </AccordionTrigger>
              <AccordionContent>
                <p className="text-zinc-400 leading-relaxed pb-2">
                  {item.a}
                </p>
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  )
}
