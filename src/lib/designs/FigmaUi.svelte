<script lang="ts">
  import ArrowUpRight from 'lucide-svelte/icons/arrow-up-right';
  import CalendarDays from 'lucide-svelte/icons/calendar-days';
  import CircleCheck from 'lucide-svelte/icons/circle-check';
  import ClipboardCheck from 'lucide-svelte/icons/clipboard-check';
  import Clock3 from 'lucide-svelte/icons/clock-3';
  import Gauge from 'lucide-svelte/icons/gauge';
  import HardHat from 'lucide-svelte/icons/hard-hat';
  import Hammer from 'lucide-svelte/icons/hammer';
  import MapPin from 'lucide-svelte/icons/map-pin';
  import Radio from 'lucide-svelte/icons/radio';
  import TriangleAlert from 'lucide-svelte/icons/triangle-alert';
  import Truck from 'lucide-svelte/icons/truck';
  import UsersRound from 'lucide-svelte/icons/users-round';
  import Wrench from 'lucide-svelte/icons/wrench';

  const liveFeed = [
    '06:42 concrete pour released at tower B',
    '07:05 foreman handoff accepted',
    '07:18 lift 04 inspection due',
    '07:31 north gate delivery queued'
  ];

  const scheduleRows = [
    { time: '06:30', task: 'Safety huddle', zone: 'Deck 12', status: 'Closed' },
    { time: '07:15', task: 'MEP rough-in', zone: 'Core west', status: 'Live' },
    { time: '09:40', task: 'Steel delivery', zone: 'Gate N', status: 'Hold' },
    { time: '13:00', task: 'Envelope punch', zone: 'Podium', status: 'Ready' }
  ];

  const reportCards = [
    { label: 'Daily logs', value: '18', detail: '14 synced from mobile' },
    { label: 'Open RFIs', value: '07', detail: '2 blocking schedule' },
    { label: 'Photo evidence', value: '246', detail: 'Tagged by grid line' }
  ];

  const crews = [
    { name: 'Concrete', count: '34', zone: 'Tower B', signal: 'On plan' },
    { name: 'Electrical', count: '16', zone: 'Level 08', signal: 'Needs access' },
    { name: 'Finishers', count: '22', zone: 'Podium', signal: 'Ahead' }
  ];

  const maintenanceTickets = [
    { asset: 'Hoist 02', issue: 'Brake inspection', priority: '11:30' },
    { asset: 'Generator E', issue: 'Fuel sensor drift', priority: 'Today' },
    { asset: 'Pump skid', issue: 'Seal kit request', priority: 'Queued' }
  ];
</script>

<section class="figma-study min-h-screen bg-[var(--canvas)] text-[var(--ink)]">
  <header class="sticky top-0 z-30 border-b border-[var(--hairline)] bg-[var(--canvas)]">
    <div class="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-5 md:px-8">
      <a href="/" class="flex items-center gap-3" aria-label="Montague home">
        <span class="grid h-9 w-9 place-items-center rounded-full bg-[var(--ink)] text-[var(--canvas)]">
          <HardHat size={18} strokeWidth={2.4} />
        </span>
        <span class="text-[18px] font-[540] tracking-[-0.18px]">Montague</span>
      </a>

      <nav class="hidden items-center gap-8 text-[16px] font-[330] tracking-[-0.14px] md:flex">
        <a href="#schedule">Schedule</a>
        <a href="#reports">Reports</a>
        <a href="#crews">Crews</a>
        <a href="#maintenance">Maintenance</a>
      </nav>

      <div class="flex items-center gap-2">
        <button class="hidden min-h-11 rounded-full bg-white px-5 pb-[10px] pt-2 text-[18px] font-[480] tracking-[-0.1px] md:inline-flex">
          Dispatch board
        </button>
        <button class="min-h-11 rounded-full bg-[var(--ink)] px-5 py-2 text-[18px] font-[480] tracking-[-0.1px] text-[var(--canvas)]">
          Push update
        </button>
      </div>
    </div>
  </header>

  <div class="overflow-hidden bg-[var(--ink)] text-[var(--canvas)]">
    <div class="marquee flex h-9 items-center gap-10 whitespace-nowrap text-[13px] font-[400] uppercase tracking-[0.12em]">
      {#each [...liveFeed, ...liveFeed] as item}
        <span class="inline-flex items-center gap-3">
          <Radio size={14} />
          {item}
        </span>
      {/each}
    </div>
  </div>

  <main class="mx-auto max-w-[1280px] px-5 py-12 md:px-8 md:py-16">
    <section class="grid gap-8 lg:grid-cols-[minmax(0,1.15fr)_420px] lg:items-end">
      <div class="reveal">
        <p class="eyebrow">FIELD OPS / MAY 01 / 07:34 ET</p>
        <h1 class="mt-5 max-w-5xl text-[clamp(3.1rem,8vw,6.6rem)] font-[340] leading-[0.96] tracking-[-0.045em]">
          Today&apos;s work, cut into command shape.
        </h1>
      </div>

      <aside class="reveal rounded-[32px] border border-[var(--hairline)] bg-[var(--surface-soft)] p-4 delay-100">
        <div class="rounded-[24px] bg-[var(--ink)] p-6 text-[var(--canvas)]">
          <div class="flex items-start justify-between gap-5">
            <div>
              <p class="caption">CRITICAL PATH</p>
              <p class="mt-5 text-[58px] font-[340] leading-none tracking-[-0.04em]">92%</p>
            </div>
            <span class="grid h-11 w-11 place-items-center rounded-full bg-white/15">
              <Gauge size={21} />
            </span>
          </div>
          <p class="mt-8 text-[20px] font-[330] leading-[1.35] tracking-[-0.14px]">
            North tower pour is active. Two dependencies need field confirmation before lunch.
          </p>
        </div>
        <div class="grid grid-cols-3 gap-2 pt-2">
          <div class="rounded-2xl bg-[var(--block-lime)] p-4">
            <p class="caption">OPEN</p>
            <p class="mt-6 text-3xl font-[540]">11</p>
          </div>
          <div class="rounded-2xl bg-[var(--block-lilac)] p-4">
            <p class="caption">CREWS</p>
            <p class="mt-6 text-3xl font-[540]">08</p>
          </div>
          <div class="rounded-2xl bg-[var(--block-cream)] p-4">
            <p class="caption">RISK</p>
            <p class="mt-6 text-3xl font-[540]">03</p>
          </div>
        </div>
      </aside>
    </section>

    <section class="mt-16 grid gap-5 lg:grid-cols-[0.95fr_1.05fr]">
      <article id="schedule" class="color-block reveal bg-[var(--block-lime)]">
        <div class="flex flex-wrap items-start justify-between gap-6">
          <div>
            <p class="eyebrow">SCHEDULE</p>
            <h2 class="mt-4 max-w-xl text-[clamp(2.4rem,5vw,4rem)] font-[340] leading-[1.03] tracking-[-0.028em]">
              The next eight hours, without the meeting.
            </h2>
          </div>
          <span class="icon-pill">
            <CalendarDays size={22} />
          </span>
        </div>

        <div class="mt-10 overflow-hidden rounded-3xl bg-[var(--canvas)]">
          {#each scheduleRows as row}
            <div class="grid grid-cols-[72px_minmax(0,1fr)] gap-4 border-b border-[var(--hairline-soft)] p-4 last:border-b-0 md:grid-cols-[80px_minmax(0,1fr)_120px_88px]">
              <p class="caption pt-1">{row.time}</p>
              <div>
                <p class="text-[20px] font-[540] tracking-[-0.2px]">{row.task}</p>
                <p class="mt-1 text-[16px] font-[330] tracking-[-0.14px] md:hidden">{row.zone} / {row.status}</p>
              </div>
              <p class="hidden text-[18px] font-[330] tracking-[-0.2px] md:block">{row.zone}</p>
              <p class="hidden text-[18px] font-[480] tracking-[-0.2px] md:block">{row.status}</p>
            </div>
          {/each}
        </div>
      </article>

      <article id="reports" class="color-block reveal bg-[var(--block-lilac)] delay-100">
        <div class="flex flex-wrap items-start justify-between gap-6">
          <div>
            <p class="eyebrow">REPORTS</p>
            <h2 class="mt-4 max-w-2xl text-[clamp(2.3rem,4.8vw,4rem)] font-[340] leading-[1.03] tracking-[-0.028em]">
              Paperwork that reads like a field signal.
            </h2>
          </div>
          <span class="icon-pill">
            <ClipboardCheck size={22} />
          </span>
        </div>

        <div class="mt-10 grid gap-3 md:grid-cols-3">
          {#each reportCards as card}
            <div class="rounded-3xl bg-[var(--canvas)] p-5">
              <p class="caption">{card.label}</p>
              <p class="mt-8 text-[54px] font-[340] leading-none tracking-[-0.04em]">{card.value}</p>
              <p class="mt-4 text-[17px] font-[330] leading-[1.35] tracking-[-0.14px]">{card.detail}</p>
            </div>
          {/each}
        </div>

        <div class="mt-4 rounded-3xl bg-[var(--ink)] p-5 text-[var(--canvas)]">
          <div class="flex items-center justify-between gap-4">
            <p class="text-[22px] font-[540] tracking-[-0.24px]">Inspector packet ready</p>
            <button class="grid h-11 w-11 place-items-center rounded-full bg-white/15" aria-label="Open inspector packet">
              <ArrowUpRight size={21} />
            </button>
          </div>
        </div>
      </article>
    </section>

    <section class="my-16 grid gap-8 rounded-[32px] border border-[var(--hairline)] bg-[var(--surface-soft)] p-5 md:p-8 lg:grid-cols-[1fr_1.25fr]">
      <div class="reveal self-end">
        <p class="eyebrow">COMMAND CENTER</p>
        <h2 class="mt-4 text-[clamp(2.6rem,6vw,5.2rem)] font-[340] leading-[0.98] tracking-[-0.04em]">
          Dispatch sees the job as it is.
        </h2>
      </div>
      <div class="reveal grid gap-3 delay-100 md:grid-cols-2">
        <div class="rounded-[24px] bg-[var(--canvas)] p-5">
          <p class="caption">ACTIVE ZONES</p>
          <div class="mt-8 grid grid-cols-2 gap-2">
            <span class="zone bg-[var(--block-mint)]">B-12</span>
            <span class="zone bg-[var(--block-cream)]">W-08</span>
            <span class="zone bg-[var(--block-pink)]">P-01</span>
            <span class="zone bg-[var(--block-coral)]">N-Gate</span>
          </div>
        </div>
        <div class="rounded-[24px] bg-[var(--ink)] p-5 text-[var(--canvas)]">
          <p class="caption">RADIO TRAFFIC</p>
          <p class="mt-8 text-[24px] font-[540] leading-[1.25] tracking-[-0.26px]">
            “Hold lift 04 until maintenance clears the brake inspection.”
          </p>
          <div class="mt-8 flex items-center gap-2">
            <span class="h-3 w-3 rounded-full bg-[var(--block-lime)]"></span>
            <span class="caption">LIVE CHANNEL 3</span>
          </div>
        </div>
      </div>
    </section>

    <section class="grid gap-5 lg:grid-cols-[1.05fr_0.95fr]">
      <article id="crews" class="color-block reveal bg-[var(--block-cream)]">
        <div class="flex flex-wrap items-start justify-between gap-6">
          <div>
            <p class="eyebrow">CREWS</p>
            <h2 class="mt-4 max-w-xl text-[clamp(2.3rem,4.8vw,4rem)] font-[340] leading-[1.03] tracking-[-0.028em]">
              People, zones, blockers, one foreman view.
            </h2>
          </div>
          <span class="icon-pill">
            <UsersRound size={22} />
          </span>
        </div>

        <div class="mt-10 space-y-3">
          {#each crews as crew}
            <div class="grid gap-3 rounded-3xl bg-[var(--canvas)] p-5 md:grid-cols-[minmax(0,1fr)_72px_132px] md:items-center">
              <div class="flex items-center gap-4">
                <span class="grid h-12 w-12 place-items-center rounded-full bg-[var(--surface-soft)]">
                  <Hammer size={19} />
                </span>
                <div>
                  <p class="text-[22px] font-[540] tracking-[-0.24px]">{crew.name}</p>
                  <p class="mt-1 text-[16px] font-[330] tracking-[-0.14px]">
                    <MapPin class="mr-1 inline" size={15} />
                    {crew.zone}
                  </p>
                </div>
              </div>
              <p class="text-[36px] font-[340] leading-none tracking-[-0.04em]">{crew.count}</p>
              <p class="rounded-full bg-[var(--ink)] px-4 py-2 text-center text-[15px] font-[480] tracking-[-0.1px] text-[var(--canvas)]">
                {crew.signal}
              </p>
            </div>
          {/each}
        </div>
      </article>

      <article id="maintenance" class="color-block reveal bg-[var(--block-pink)] delay-100">
        <div class="flex flex-wrap items-start justify-between gap-6">
          <div>
            <p class="eyebrow">MAINTENANCE</p>
            <h2 class="mt-4 max-w-xl text-[clamp(2.3rem,4.8vw,4rem)] font-[340] leading-[1.03] tracking-[-0.028em]">
              Keep assets out of the rumor mill.
            </h2>
          </div>
          <span class="icon-pill">
            <Wrench size={22} />
          </span>
        </div>

        <div class="mt-10 rounded-3xl bg-[var(--canvas)] p-4">
          <div class="flex items-center gap-3 rounded-2xl bg-[var(--block-coral)] p-4">
            <span class="grid h-11 w-11 place-items-center rounded-full bg-[var(--canvas)]">
              <TriangleAlert size={20} />
            </span>
            <div>
              <p class="text-[21px] font-[540] tracking-[-0.22px]">One stoppage risk</p>
              <p class="text-[16px] font-[330] tracking-[-0.14px]">Hoist 02 must clear before vertical deliveries resume.</p>
            </div>
          </div>

          <div class="mt-4 space-y-2">
            {#each maintenanceTickets as ticket}
              <div class="grid grid-cols-[44px_minmax(0,1fr)_72px] items-center gap-3 border-b border-[var(--hairline-soft)] py-3 last:border-b-0">
                <span class="grid h-10 w-10 place-items-center rounded-full bg-[var(--surface-soft)]">
                  <Truck size={18} />
                </span>
                <div>
                  <p class="text-[18px] font-[540] tracking-[-0.18px]">{ticket.asset}</p>
                  <p class="text-[15px] font-[330] tracking-[-0.12px]">{ticket.issue}</p>
                </div>
                <p class="caption text-right">{ticket.priority}</p>
              </div>
            {/each}
          </div>
        </div>
      </article>
    </section>

    <section class="mt-16 overflow-hidden rounded-[32px] bg-[var(--ink)] text-[var(--canvas)]">
      <div class="grid gap-8 p-6 md:p-10 lg:grid-cols-[1fr_0.75fr] lg:items-end">
        <div class="reveal">
          <p class="eyebrow text-[var(--canvas)]">NEXT DECISION</p>
          <h2 class="mt-5 max-w-3xl text-[clamp(2.7rem,6vw,5rem)] font-[340] leading-[0.98] tracking-[-0.04em]">
            Release the podium crews when inspection photos land.
          </h2>
        </div>
        <div class="reveal grid gap-3 delay-100">
          <button class="flex min-h-12 items-center justify-between rounded-full bg-[var(--canvas)] px-5 py-3 text-[19px] font-[480] tracking-[-0.1px] text-[var(--ink)]">
            Approve resequence <CircleCheck size={21} />
          </button>
          <button class="flex min-h-12 items-center justify-between rounded-full bg-white/15 px-5 py-3 text-[19px] font-[480] tracking-[-0.1px] text-[var(--canvas)]">
            Set 30 min timer <Clock3 size={21} />
          </button>
        </div>
      </div>
    </section>
  </main>
</section>

<style>
  .figma-study {
    --ink: #000000;
    --canvas: #ffffff;
    --hairline: #e6e6e6;
    --hairline-soft: #f1f1f1;
    --surface-soft: #f7f7f5;
    --block-lime: #dceeb1;
    --block-lilac: #c5b0f4;
    --block-cream: #f4ecd6;
    --block-pink: #efd4d4;
    --block-mint: #c8e6cd;
    --block-coral: #f3c9b6;
    font-family: figmaSans, "SF Pro Display", "Helvetica Neue", ui-sans-serif, system-ui, sans-serif;
    font-feature-settings: "kern";
  }

  .eyebrow,
  .caption {
    font-family: figmaMono, "SF Mono", Menlo, Consolas, monospace;
    font-weight: 400;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .eyebrow {
    font-size: 16px;
    line-height: 1.3;
  }

  .caption {
    font-size: 12px;
    line-height: 1;
  }

  .color-block {
    border-radius: 24px;
    padding: clamp(1.5rem, 4vw, 3rem);
  }

  .icon-pill {
    display: grid;
    width: 48px;
    height: 48px;
    place-items: center;
    border-radius: 9999px;
    background: var(--canvas);
  }

  .zone {
    min-height: 96px;
    border-radius: 18px;
    padding: 14px;
    font-size: 24px;
    font-weight: 540;
    letter-spacing: -0.02em;
  }

  .marquee {
    width: max-content;
    animation: slide 32s linear infinite;
  }

  .reveal {
    animation: rise 700ms cubic-bezier(0.2, 0.8, 0.2, 1) both;
  }

  .delay-100 {
    animation-delay: 100ms;
  }

  @keyframes slide {
    from {
      transform: translateX(0);
    }
    to {
      transform: translateX(-50%);
    }
  }

  @keyframes rise {
    from {
      opacity: 0;
      transform: translateY(18px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (max-width: 767px) {
    .color-block {
      margin-right: -1.25rem;
      margin-left: -1.25rem;
      border-radius: 0;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .marquee,
    .reveal {
      animation: none;
    }
  }
</style>
