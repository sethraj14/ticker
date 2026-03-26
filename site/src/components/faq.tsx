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
    <section className="py-32 px-6" id="faq">
      <div className="mx-auto max-w-3xl">
        <h2 className="text-3xl font-bold text-white font-headline mb-12 text-center">
          Frequently Asked Questions
        </h2>

        <Accordion className="space-y-2">
          {FAQ.map((item, index) => (
            <AccordionItem
              key={item.q}
              value={index}
              className="border-b border-zinc-800 px-0"
            >
              <AccordionTrigger className="text-white font-bold font-headline hover:no-underline py-6 text-left text-base">
                {item.q}
              </AccordionTrigger>
              <AccordionContent>
                <p className="text-zinc-400 text-sm leading-relaxed pb-4">
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
