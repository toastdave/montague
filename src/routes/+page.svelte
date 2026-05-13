<script lang="ts">
  import { ArrowUpRight } from 'lucide-svelte';

  const studies = [
    {
      name: 'Airbnb',
      href: '/airbnb',
      source: 'DESIGN.md',
      description: 'Warm marketplace UI with generous white space, Rausch red accents, and friendly rounded search patterns.',
      accent: '#ff385c',
      background: '#fff7f8'
    },
    {
      name: 'Figma',
      href: '/figma',
      source: 'figma/DESIGN.md',
      description: 'Black-and-white editorial framing interrupted by saturated color-block panels and playful tool surfaces.',
      accent: '#000000',
      background: '#f7f7f5'
    },
    {
      name: 'Linear',
      href: '/linear',
      source: 'linear.app/DESIGN.md',
      description: 'Near-black product UI with dense operational panels, restrained lavender focus, and charcoal hierarchy.',
      accent: '#5e6ad2',
      background: '#f4f5ff'
    },
    {
      name: 'Stripe',
      href: '/stripe',
      source: 'stripe/DESIGN.md',
      description: 'Financial-grade white canvas with light-weight navy type, precise cards, and blue-tinted depth.',
      accent: '#533afd',
      background: '#f6f9fc'
    }
  ];
</script>

<svelte:head>
  <title>Montague UI Studies</title>
  <meta
    name="description"
    content="Four single-component Svelte UI studies for Montague, each mapped to a separate design markdown file."
  />
</svelte:head>

<main class="min-h-screen bg-[#f4f0e8] px-5 py-8 text-[#1f2933] sm:px-8 lg:px-12">
  <section class="mx-auto flex max-w-7xl flex-col gap-10">
    <header class="grid gap-6 border-b border-[#d8d0c1] pb-8 lg:grid-cols-[1fr_360px] lg:items-end">
      <div>
        <p class="text-sm font-semibold uppercase tracking-[0.16em] text-[#7a4d2f]">Montague interface studies</p>
        <h1 class="mt-4 max-w-4xl text-5xl font-semibold leading-[1.02] text-[#111827] md:text-7xl">
          Four design systems applied to construction operations.
        </h1>
      </div>
      <p class="max-w-xl text-base leading-7 text-[#53606c]">
        Each route is a separate Svelte component, built from its own design markdown file. Use this page as the index for comparing tone, density, and workflow fit.
      </p>
    </header>

    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      {#each studies as study}
        <a
          class="group flex min-h-[280px] flex-col justify-between rounded-[8px] border border-[#d8d0c1] bg-white p-5 shadow-[0_18px_45px_rgba(47,38,24,0.08)] transition duration-200 hover:-translate-y-1 hover:shadow-[0_24px_60px_rgba(47,38,24,0.12)]"
          href={study.href}
          style={`background: linear-gradient(180deg, ${study.background} 0%, #ffffff 62%);`}
        >
          <div>
            <div class="flex items-start justify-between gap-4">
              <span class="h-3 w-12 rounded-full" style={`background: ${study.accent};`}></span>
              <span class="grid h-9 w-9 place-items-center rounded-full border border-[#d8d0c1] bg-white text-[#1f2933] transition group-hover:border-[#1f2933]">
                <ArrowUpRight size={17} strokeWidth={1.8} />
              </span>
            </div>
            <h2 class="mt-10 text-3xl font-semibold tracking-[-0.02em]">{study.name}</h2>
            <p class="mt-3 text-sm font-medium text-[#7a4d2f]">{study.source}</p>
          </div>
          <p class="mt-8 text-sm leading-6 text-[#53606c]">{study.description}</p>
        </a>
      {/each}
    </div>
  </section>
</main>
