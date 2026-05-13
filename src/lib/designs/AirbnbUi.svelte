<script>
  import {
    CalendarDays,
    ChevronRight,
    CircleUserRound,
    Clock3,
    Globe2,
    HardHat,
    Heart,
    MapPin,
    Menu,
    Search,
    SlidersHorizontal,
    Star,
    Truck,
    UsersRound
  } from 'lucide-svelte';

  const productTabs = [
    { label: 'Sites', icon: HardHat, active: true },
    { label: 'Crews', icon: UsersRound, badge: 'NEW' },
    { label: 'Services', icon: Truck, badge: 'NEW' }
  ];

  const categories = [
    'Today',
    'Concrete',
    'MEP',
    'Equipment',
    'Inspections',
    'Closeout',
    'Weather risk',
    'Labor gaps'
  ];

  const dispatchCards = [
    {
      title: 'Mercer Tower podium pour',
      place: 'Site 14B, South Loop',
      window: 'Today, 6:00 AM - 2:00 PM',
      crew: '24 concrete hands + 3 finishers',
      price: '$18.4k committed',
      rating: '4.96',
      tag: 'Crew favorite',
      status: 'Ready',
      saved: true,
      gradient: 'from-[#f9d5be] via-[#e6b08f] to-[#8e5c46]',
      accent: 'bg-[#ff385c]'
    },
    {
      title: 'Night shift MEP rough-in',
      place: 'Harbor Clinic, Level 5',
      window: 'Tonight, 8:00 PM - 4:00 AM',
      crew: '12 electricians + lift support',
      price: '$9.2k estimate',
      rating: '4.88',
      tag: 'High demand',
      status: '1 gap',
      gradient: 'from-[#dbeafe] via-[#93c5fd] to-[#1f4b75]',
      accent: 'bg-[#222222]'
    },
    {
      title: 'Crane slot for steel picks',
      place: 'Foundry Yard, Bay C',
      window: 'Fri, 10:30 AM - 1:00 PM',
      crew: 'Operator, rigger, signal person',
      price: '$6.8k hold',
      rating: '4.91',
      tag: 'Verified',
      status: 'Hold',
      gradient: 'from-[#fef3c7] via-[#fbbf24] to-[#7c4a03]',
      accent: 'bg-[#92174d]'
    },
    {
      title: 'Envelope punch walk',
      place: 'Aster Residences, East face',
      window: 'Tomorrow, 9:00 AM - 12:00 PM',
      crew: 'QA lead + facade vendor',
      price: '$3.1k planned',
      rating: '4.82',
      tag: 'Low risk',
      status: 'Booked',
      gradient: 'from-[#dcfce7] via-[#86efac] to-[#14532d]',
      accent: 'bg-[#ff385c]'
    }
  ];

  const timeline = [
    { time: '05:45', title: 'Gate opens at Mercer', meta: 'Badge sync complete', tone: 'rausch' },
    { time: '07:15', title: 'Batch plant departure', meta: '12 trucks sequenced', tone: 'ink' },
    { time: '10:30', title: 'Inspector arrival window', meta: 'Permit packet attached', tone: 'soft' },
    { time: '14:00', title: 'Crew release target', meta: 'Overtime risk: low', tone: 'soft' }
  ];
</script>

<svelte:head>
  <title>Airbnb field operations study | Montague</title>
</svelte:head>

<section class="airbnb-study min-h-screen bg-white text-[#222222]">
  <header class="sticky top-0 z-30 border-b border-[#ebebeb] bg-white/95 backdrop-blur">
    <div class="mx-auto flex h-20 max-w-[1440px] items-center justify-between px-5 sm:px-8 lg:px-12">
      <a href="/airbnb" class="flex items-center gap-2" aria-label="Montague Airbnb style study">
        <span class="grid h-9 w-9 place-items-center rounded-full bg-[#ff385c] text-white">
          <HardHat size={19} strokeWidth={2.2} />
        </span>
        <span class="text-[18px] font-semibold tracking-[-0.02em] text-[#ff385c]">montague</span>
      </a>

      <nav class="hidden items-center gap-8 md:flex" aria-label="Marketplace sections">
        {#each productTabs as tab}
          <a
            href="/airbnb"
            class={`relative flex h-16 flex-col items-center justify-center gap-1 text-[16px] font-semibold ${
              tab.active ? 'text-[#222222]' : 'text-[#6a6a6a]'
            }`}
          >
            <span class="relative">
              <svelte:component this={tab.icon} size={26} strokeWidth={1.8} />
              {#if tab.badge}
                <span
                  class="absolute -right-6 -top-3 rounded-full border border-[#dddddd] bg-white px-1.5 py-0.5 text-[8px] font-bold uppercase leading-none tracking-[0.04em] text-[#222222]"
                >
                  {tab.badge}
                </span>
              {/if}
            </span>
            <span>{tab.label}</span>
            {#if tab.active}
              <span class="absolute bottom-0 h-0.5 w-12 rounded-full bg-[#222222]"></span>
            {/if}
          </a>
        {/each}
      </nav>

      <div class="flex items-center gap-2">
        <a href="/airbnb" class="hidden rounded-full px-4 py-3 text-[14px] font-medium hover:bg-[#f7f7f7] lg:block">
          Open dispatch
        </a>
        <button class="hidden h-10 w-10 place-items-center rounded-full hover:bg-[#f7f7f7] sm:grid" aria-label="Language">
          <Globe2 size={18} />
        </button>
        <button
          class="flex h-11 items-center gap-3 rounded-full border border-[#dddddd] bg-white py-1.5 pl-3 pr-1.5 shadow-[0_2px_6px_rgba(0,0,0,0.04)]"
          aria-label="Account menu"
        >
          <Menu size={18} />
          <span class="grid h-8 w-8 place-items-center rounded-full bg-[#f2f2f2]">
            <CircleUserRound size={20} />
          </span>
        </button>
      </div>
    </div>
  </header>

  <main>
    <section class="border-b border-[#ebebeb] bg-white">
      <div class="mx-auto max-w-[1280px] px-5 py-8 sm:px-8 lg:px-12 lg:py-10">
        <div class="mx-auto max-w-[900px]">
          <div
            class="search-shell grid min-h-16 grid-cols-1 items-center rounded-full border border-[#dddddd] bg-white p-2 shadow-[0_2px_6px_rgba(0,0,0,0.04),0_4px_8px_rgba(0,0,0,0.08)] md:grid-cols-[1.1fr_0.85fr_0.85fr_auto]"
          >
            <button class="search-segment rounded-full px-6 py-3 text-left hover:bg-[#f7f7f7]">
              <span class="block text-[12px] font-bold leading-4">Where</span>
              <span class="block truncate text-[14px] text-[#6a6a6a]">Project, yard, or floor</span>
            </button>
            <button class="search-segment border-[#dddddd] px-6 py-3 text-left hover:bg-[#f7f7f7] md:border-l">
              <span class="block text-[12px] font-bold leading-4">When</span>
              <span class="block truncate text-[14px] text-[#6a6a6a]">Next 72 hours</span>
            </button>
            <button class="search-segment border-[#dddddd] px-6 py-3 text-left hover:bg-[#f7f7f7] md:border-l">
              <span class="block text-[12px] font-bold leading-4">Who</span>
              <span class="block truncate text-[14px] text-[#6a6a6a]">Crew, vendor, inspector</span>
            </button>
            <button
              class="mt-2 grid h-12 w-full place-items-center rounded-full bg-[#ff385c] text-white transition hover:bg-[#e00b41] md:mt-0 md:w-12"
              aria-label="Search"
            >
              <Search size={20} strokeWidth={2.6} />
            </button>
          </div>
        </div>

        <div class="scrollbar-none mt-8 flex gap-3 overflow-x-auto pb-1" aria-label="Operational filters">
          {#each categories as category, index}
            <button
              class={`shrink-0 rounded-full border px-5 py-3 text-[14px] font-medium ${
                index === 0
                  ? 'border-[#222222] bg-[#222222] text-white'
                  : 'border-[#dddddd] bg-white text-[#6a6a6a] hover:border-[#222222] hover:text-[#222222]'
              }`}
            >
              {category}
            </button>
          {/each}
          <button class="ml-auto hidden shrink-0 items-center gap-2 rounded-full border border-[#dddddd] px-5 py-3 text-[14px] font-medium text-[#222222] lg:flex">
            <SlidersHorizontal size={16} />
            Filters
          </button>
        </div>
      </div>
    </section>

    <section class="mx-auto grid max-w-[1440px] gap-8 px-5 py-10 sm:px-8 lg:grid-cols-[minmax(0,1fr)_360px] lg:px-12 lg:py-12">
      <div>
        <div class="mb-8 flex flex-col justify-between gap-5 md:flex-row md:items-end">
          <div>
            <p class="mb-2 text-[14px] font-medium text-[#6a6a6a]">Chicago portfolio · live dispatch board</p>
            <h1 class="max-w-3xl text-[28px] font-bold leading-[1.18] tracking-[-0.02em] text-[#222222] sm:text-[34px]">
              Book the right crew, slot, and equipment before the morning huddle.
            </h1>
          </div>
          <a href="/airbnb" class="inline-flex items-center gap-2 text-[14px] font-medium underline underline-offset-4">
            View marketplace map <ChevronRight size={16} />
          </a>
        </div>

        <div class="grid gap-x-6 gap-y-10 md:grid-cols-2 xl:grid-cols-4">
          {#each dispatchCards as card}
            <article class="group">
              <div class={`relative aspect-[1.02] overflow-hidden rounded-[14px] bg-gradient-to-br ${card.gradient}`}>
                <div class="absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.72),transparent_28%),linear-gradient(135deg,rgba(255,255,255,0.18),transparent_48%)]"></div>
                <div class="absolute bottom-5 left-5 right-5 rounded-[20px] bg-white/88 p-4 shadow-[0_2px_6px_rgba(0,0,0,0.08)] backdrop-blur">
                  <div class="flex items-center justify-between gap-3">
                    <span class="text-[12px] font-bold text-[#222222]">{card.status}</span>
                    <span class={`h-2.5 w-2.5 rounded-full ${card.accent}`}></span>
                  </div>
                  <div class="mt-3 grid grid-cols-3 gap-2 text-[11px] font-medium text-[#6a6a6a]">
                    <span class="rounded-full bg-[#f7f7f7] px-2 py-1 text-center">Labor</span>
                    <span class="rounded-full bg-[#f7f7f7] px-2 py-1 text-center">Safety</span>
                    <span class="rounded-full bg-[#f7f7f7] px-2 py-1 text-center">Cost</span>
                  </div>
                </div>
                <span class="absolute left-3 top-3 rounded-full bg-white px-3 py-1.5 text-[11px] font-semibold shadow-[0_2px_6px_rgba(0,0,0,0.08)]">
                  {card.tag}
                </span>
                <button
                  class={`absolute right-3 top-3 grid h-9 w-9 place-items-center rounded-full bg-white/90 shadow-[0_2px_6px_rgba(0,0,0,0.08)] ${
                    card.saved ? 'text-[#ff385c]' : 'text-[#222222]'
                  }`}
                  aria-label="Save dispatch card"
                >
                  <Heart size={19} fill={card.saved ? 'currentColor' : 'none'} />
                </button>
                <div class="absolute bottom-2 left-1/2 flex -translate-x-1/2 gap-1">
                  <span class="h-1.5 w-1.5 rounded-full bg-white"></span>
                  <span class="h-1.5 w-1.5 rounded-full bg-white/60"></span>
                  <span class="h-1.5 w-1.5 rounded-full bg-white/60"></span>
                </div>
              </div>

              <div class="pt-3 text-[14px] leading-[1.43]">
                <div class="flex items-start justify-between gap-3">
                  <h2 class="font-semibold text-[#222222]">{card.title}</h2>
                  <span class="flex shrink-0 items-center gap-1 text-[#222222]">
                    <Star size={13} fill="currentColor" />
                    {card.rating}
                  </span>
                </div>
                <p class="mt-1 text-[#6a6a6a]">{card.place}</p>
                <p class="text-[#6a6a6a]">{card.window}</p>
                <p class="text-[#6a6a6a]">{card.crew}</p>
                <p class="mt-1 font-semibold text-[#222222]">{card.price}</p>
              </div>
            </article>
          {/each}
        </div>

        <section class="mt-12 rounded-[24px] border border-[#ebebeb] p-5 sm:p-8">
          <div class="flex flex-col justify-between gap-5 md:flex-row md:items-center">
            <div>
              <p class="text-[14px] font-medium text-[#6a6a6a]">Schedule health</p>
              <h2 class="mt-1 text-[22px] font-medium leading-[1.18] tracking-[-0.02em]">Today’s work is bookable, visible, and sequenced.</h2>
            </div>
            <div class="flex gap-3">
              <div class="rounded-[20px] bg-[#f7f7f7] px-5 py-4">
                <p class="text-[22px] font-bold">92%</p>
                <p class="text-[13px] text-[#6a6a6a]">crew coverage</p>
              </div>
              <div class="rounded-[20px] bg-[#f7f7f7] px-5 py-4">
                <p class="text-[22px] font-bold">7</p>
                <p class="text-[13px] text-[#6a6a6a]">open slots</p>
              </div>
            </div>
          </div>
        </section>
      </div>

      <aside class="lg:sticky lg:top-28 lg:self-start">
        <div class="rounded-[20px] border border-[#dddddd] bg-white p-6 shadow-[0_2px_6px_rgba(0,0,0,0.04),0_4px_8px_rgba(0,0,0,0.10)]">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-[14px] text-[#6a6a6a]">Dispatch basket</p>
              <h2 class="mt-1 text-[21px] font-bold leading-[1.3]">Mercer Tower podium pour</h2>
            </div>
            <div class="text-right">
              <p class="text-[22px] font-bold">4.96</p>
              <p class="text-[12px] text-[#6a6a6a]">vendor score</p>
            </div>
          </div>

          <div class="mt-6 overflow-hidden rounded-[14px] border border-[#222222]">
            <div class="grid grid-cols-2">
              <div class="border-r border-b border-[#222222] p-3">
                <p class="text-[10px] font-bold uppercase tracking-[0.08em]">Start</p>
                <p class="mt-1 text-[14px]">May 2, 6:00 AM</p>
              </div>
              <div class="border-b border-[#222222] p-3">
                <p class="text-[10px] font-bold uppercase tracking-[0.08em]">Release</p>
                <p class="mt-1 text-[14px]">May 2, 2:00 PM</p>
              </div>
            </div>
            <div class="p-3">
              <p class="text-[10px] font-bold uppercase tracking-[0.08em]">Crew</p>
              <p class="mt-1 text-[14px]">24 concrete hands, 3 finishers, 1 pump operator</p>
            </div>
          </div>

          <button class="mt-5 h-12 w-full rounded-lg bg-[#ff385c] text-[16px] font-medium text-white hover:bg-[#e00b41]">
            Reserve crew window
          </button>
          <p class="mt-3 text-center text-[13px] text-[#6a6a6a]">No purchase order is issued until dispatch confirms.</p>

          <div class="mt-6 space-y-4 border-t border-[#ebebeb] pt-6">
            <div class="flex justify-between text-[14px]">
              <span class="text-[#6a6a6a]">Labor block</span>
              <span>$12,800</span>
            </div>
            <div class="flex justify-between text-[14px]">
              <span class="text-[#6a6a6a]">Pump + trucks</span>
              <span>$4,900</span>
            </div>
            <div class="flex justify-between text-[14px]">
              <span class="text-[#6a6a6a]">Safety standby</span>
              <span>$700</span>
            </div>
            <div class="flex justify-between border-t border-[#ebebeb] pt-4 text-[16px] font-semibold">
              <span>Total hold</span>
              <span>$18,400</span>
            </div>
          </div>
        </div>

        <div class="mt-6 rounded-[20px] bg-[#f7f7f7] p-5">
          <div class="flex items-center gap-2">
            <CalendarDays size={18} />
            <h3 class="text-[16px] font-semibold">Today’s sequence</h3>
          </div>
          <div class="mt-5 space-y-4">
            {#each timeline as item}
              <div class="grid grid-cols-[52px_1fr] gap-3">
                <p class="text-[13px] font-medium text-[#6a6a6a]">{item.time}</p>
                <div class="relative border-l border-[#dddddd] pl-4">
                  <span
                    class={`absolute -left-[5px] top-1 h-2.5 w-2.5 rounded-full ${
                      item.tone === 'rausch' ? 'bg-[#ff385c]' : item.tone === 'ink' ? 'bg-[#222222]' : 'bg-[#c1c1c1]'
                    }`}
                  ></span>
                  <p class="text-[14px] font-semibold">{item.title}</p>
                  <p class="mt-0.5 text-[13px] text-[#6a6a6a]">{item.meta}</p>
                </div>
              </div>
            {/each}
          </div>
        </div>
      </aside>
    </section>

    <section class="border-t border-[#ebebeb] bg-white">
      <div class="mx-auto grid max-w-[1280px] gap-4 px-5 py-12 sm:grid-cols-2 sm:px-8 lg:grid-cols-4 lg:px-12">
        <div class="rounded-[20px] bg-[#f7f7f7] p-5">
          <MapPin size={20} />
          <h3 class="mt-4 text-[16px] font-semibold">Neighborhood view</h3>
          <p class="mt-2 text-[14px] text-[#6a6a6a]">Group work by gate, hoist, laydown yard, or floor zone.</p>
        </div>
        <div class="rounded-[20px] bg-[#f7f7f7] p-5">
          <Clock3 size={20} />
          <h3 class="mt-4 text-[16px] font-semibold">Slot matching</h3>
          <p class="mt-2 text-[14px] text-[#6a6a6a]">Find the least disruptive crew window across active sites.</p>
        </div>
        <div class="rounded-[20px] bg-[#f7f7f7] p-5">
          <UsersRound size={20} />
          <h3 class="mt-4 text-[16px] font-semibold">Trusted crews</h3>
          <p class="mt-2 text-[14px] text-[#6a6a6a]">Prioritize vendors with verified safety and delivery history.</p>
        </div>
        <div class="rounded-[20px] bg-[#f7f7f7] p-5">
          <Truck size={20} />
          <h3 class="mt-4 text-[16px] font-semibold">Equipment holds</h3>
          <p class="mt-2 text-[14px] text-[#6a6a6a]">Reserve lifts, pumps, trucks, and crane time alongside labor.</p>
        </div>
      </div>
    </section>
  </main>
</section>

<style>
  .airbnb-study {
    --rausch: #ff385c;
    font-family:
      'Airbnb Cereal VF',
      Circular,
      -apple-system,
      BlinkMacSystemFont,
      'Helvetica Neue',
      sans-serif;
  }

  .search-segment {
    min-width: 0;
  }

  .scrollbar-none {
    scrollbar-width: none;
  }

  .scrollbar-none::-webkit-scrollbar {
    display: none;
  }

  article {
    transition:
      transform 180ms ease,
      filter 180ms ease;
  }

  article:hover {
    transform: translateY(-2px);
    filter: drop-shadow(0 4px 8px rgb(0 0 0 / 0.1));
  }

  @media (max-width: 767px) {
    .search-shell {
      border-radius: 32px;
    }
  }
</style>
