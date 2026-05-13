<script lang="ts">
  import {
    AlertTriangle,
    ArrowRight,
    Bell,
    CalendarClock,
    CheckCircle2,
    ChevronDown,
    CircleDot,
    ClipboardCheck,
    Clock3,
    Construction,
    FileText,
    Gauge,
    HardHat,
    MapPin,
    RadioTower,
    Search,
    Settings2,
    ShieldCheck,
    TimerReset,
    Truck,
    Wrench
  } from 'lucide-svelte';

  const shifts = [
    {
      code: '03A',
      site: 'Harbor Point Tower',
      window: '06:30 - 14:00',
      crew: 'Concrete / Level 18',
      status: 'Live',
      progress: 72
    },
    {
      code: '07F',
      site: 'Northline Transit Hub',
      window: '07:00 - 16:30',
      crew: 'MEP rough-in / Zone C',
      status: 'Blocked',
      progress: 38
    },
    {
      code: '12C',
      site: 'Foundry Office Fitout',
      window: '08:15 - 15:45',
      crew: 'Finishes / East wing',
      status: 'Review',
      progress: 54
    }
  ];

  const reports = [
    { label: 'Daily logs', count: 42, state: '31 cleared', tone: 'ok' },
    { label: 'Safety observations', count: 9, state: '2 critical', tone: 'warn' },
    { label: 'Photo packs', count: 128, state: 'Synced', tone: 'ok' },
    { label: 'RFI updates', count: 6, state: 'Pending PM', tone: 'neutral' }
  ];

  const assets = [
    { name: 'Tower crane TC-04', site: 'Harbor Point', signal: 'Online', hours: '1,284h', load: 64 },
    { name: 'Generator G-11', site: 'Northline', signal: 'Service soon', hours: '692h', load: 81 },
    { name: 'Telehandler TH-08', site: 'Foundry', signal: 'Idle', hours: '339h', load: 22 },
    { name: 'Survey rover SR-2', site: 'Harbor Point', signal: 'Online', hours: '118h', load: 48 }
  ];

  const issues = [
    {
      id: 'MNT-1428',
      title: 'Hydraulic pressure drift on TC-04',
      owner: 'Luis M.',
      age: '18m',
      priority: 'P1'
    },
    {
      id: 'MNT-1424',
      title: 'Temporary power panel label mismatch',
      owner: 'Evan R.',
      age: '41m',
      priority: 'P2'
    },
    {
      id: 'MNT-1419',
      title: 'Lift gate inspection photos incomplete',
      owner: 'Dana K.',
      age: '2h',
      priority: 'P3'
    }
  ];

  const timeRows = [
    { trade: 'Concrete', submitted: 94, variance: '+2.4h', status: 'Ready' },
    { trade: 'Electrical', submitted: 81, variance: '-5.0h', status: 'Needs edit' },
    { trade: 'Mechanical', submitted: 88, variance: '+0.5h', status: 'Ready' },
    { trade: 'Safety', submitted: 100, variance: '0.0h', status: 'Locked' }
  ];

  const navItems = ['Dispatch', 'Schedules', 'Reports', 'Assets', 'Issues', 'Time'];

  const statusClasses: Record<string, string> = {
    Live: 'border-[#263f2e] bg-[#122016] text-[#6fe087]',
    Blocked: 'border-[#4a3426] bg-[#24170f] text-[#ffb06f]',
    Review: 'border-[#34343a] bg-[#18191a] text-[#d0d6e0]'
  };

  const priorityClasses: Record<string, string> = {
    P1: 'border-[#5e6ad2]/60 bg-[#5e6ad2]/15 text-[#b8bef8]',
    P2: 'border-[#4a3426] bg-[#24170f] text-[#ffb06f]',
    P3: 'border-[#34343a] bg-[#18191a] text-[#8a8f98]'
  };

  const getStatusClass = (status: string) =>
    statusClasses[status] ?? 'border-[#34343a] bg-[#18191a] text-[#d0d6e0]';

  const getPriorityClass = (priority: string) =>
    priorityClasses[priority] ?? 'border-[#34343a] bg-[#18191a] text-[#8a8f98]';
</script>

<svelte:head>
  <title>Montague Linear Operations UI</title>
</svelte:head>

<section class="linear-shell min-h-screen overflow-hidden bg-[#010102] text-[#f7f8f8]">
  <div class="absolute inset-0 overflow-hidden" aria-hidden="true">
    <div class="grid-glow"></div>
    <div class="noise-layer"></div>
  </div>

  <div class="relative mx-auto flex min-h-screen max-w-[1560px] flex-col px-4 py-4 sm:px-6 lg:px-8">
    <header
      class="mb-4 flex flex-col gap-3 rounded-xl border border-[#23252a] bg-[#0f1011]/92 p-3 shadow-[0_18px_80px_rgba(0,0,0,0.42)] backdrop-blur md:flex-row md:items-center md:justify-between"
    >
      <div class="flex items-center gap-3">
        <div
          class="flex h-10 w-10 items-center justify-center rounded-lg border border-[#34343a] bg-[#141516]"
        >
          <Construction class="h-5 w-5 text-[#5e6ad2]" />
        </div>
        <div>
          <p class="text-[12px] font-medium uppercase tracking-[0.28em] text-[#62666d]">
            Montague field ops
          </p>
          <h1 class="text-[22px] font-semibold leading-tight tracking-[-0.04em] text-[#f7f8f8]">
            Operations control
          </h1>
        </div>
      </div>

      <div class="flex flex-col gap-2 sm:flex-row sm:items-center">
        <label
          class="flex h-10 min-w-0 items-center gap-2 rounded-lg border border-[#23252a] bg-[#010102] px-3 text-[#8a8f98] sm:w-[280px]"
        >
          <Search class="h-4 w-4 shrink-0" />
          <span class="sr-only">Search operations</span>
          <input
            class="min-w-0 flex-1 bg-transparent text-[13px] text-[#d0d6e0] outline-none placeholder:text-[#62666d]"
            placeholder="Search sites, crews, assets..."
          />
          <kbd class="hidden rounded border border-[#34343a] px-1.5 py-0.5 text-[10px] text-[#62666d] sm:block"
            >K</kbd
          >
        </label>
        <button
          type="button"
          class="inline-flex h-10 items-center justify-center gap-2 rounded-lg border border-[#34343a] bg-[#141516] px-3 text-[13px] font-medium text-[#d0d6e0] transition hover:border-[#5e6ad2]/70 hover:text-[#f7f8f8]"
        >
          <Bell class="h-4 w-4" />
          12 alerts
        </button>
        <button
          type="button"
          class="inline-flex h-10 items-center justify-center gap-2 rounded-lg bg-[#5e6ad2] px-3.5 text-[13px] font-medium text-white transition hover:bg-[#828fff]"
        >
          Shift handoff
          <ArrowRight class="h-4 w-4" />
        </button>
      </div>
    </header>

    <div class="grid flex-1 gap-4 lg:grid-cols-[236px_minmax(0,1fr)]">
      <aside
        class="rounded-xl border border-[#23252a] bg-[#0f1011]/90 p-3 backdrop-blur lg:sticky lg:top-4 lg:h-[calc(100vh-2rem)]"
      >
        <div class="flex h-full flex-col">
          <div class="mb-4 rounded-lg border border-[#23252a] bg-[#010102] p-3">
            <div class="mb-3 flex items-center justify-between">
              <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                Workspace
              </p>
              <ChevronDown class="h-4 w-4 text-[#62666d]" />
            </div>
            <div class="flex items-center gap-2">
              <div class="h-2 w-2 rounded-full bg-[#27a644] shadow-[0_0_20px_rgba(39,166,68,0.7)]"></div>
              <p class="text-sm font-medium text-[#f7f8f8]">Northeast region</p>
            </div>
          </div>

          <nav class="space-y-1">
            {#each navItems as item}
              <a
                href="/linear"
                class={`flex items-center justify-between rounded-lg px-3 py-2 text-[13px] transition ${
                  item === 'Schedules'
                    ? 'bg-[#18191a] text-[#f7f8f8]'
                    : 'text-[#8a8f98] hover:bg-[#141516] hover:text-[#d0d6e0]'
                }`}
              >
                <span class="flex items-center gap-2">
                  <CircleDot class={`h-3 w-3 ${item === 'Schedules' ? 'text-[#5e6ad2]' : 'text-[#3e3e44]'}`} />
                  {item}
                </span>
                {#if item === 'Issues'}
                  <span class="rounded-full bg-[#5e6ad2]/15 px-2 py-0.5 text-[11px] text-[#b8bef8]">3</span>
                {/if}
              </a>
            {/each}
          </nav>

          <div class="mt-auto space-y-3 pt-5">
            <div class="rounded-lg border border-[#23252a] bg-[#141516] p-3">
              <div class="mb-2 flex items-center gap-2 text-[#d0d6e0]">
                <ShieldCheck class="h-4 w-4 text-[#5e6ad2]" />
                <p class="text-[13px] font-medium">Compliance lock</p>
              </div>
              <p class="text-[12px] leading-5 text-[#8a8f98]">
                16 of 18 active crews have complete safety briefing signatures.
              </p>
            </div>
            <button
              type="button"
              class="flex w-full items-center justify-center gap-2 rounded-lg border border-[#23252a] bg-[#010102] px-3 py-2 text-[13px] text-[#8a8f98] transition hover:border-[#34343a] hover:text-[#d0d6e0]"
            >
              <Settings2 class="h-4 w-4" />
              Console settings
            </button>
          </div>
        </div>
      </aside>

      <main class="min-w-0 space-y-4">
        <section class="grid gap-4 xl:grid-cols-[minmax(0,1.35fr)_minmax(360px,0.65fr)]">
          <div class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4 shadow-[0_18px_80px_rgba(0,0,0,0.38)]">
            <div class="mb-5 flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
              <div>
                <p class="mb-2 text-[12px] font-medium uppercase tracking-[0.28em] text-[#62666d]">
                  Schedule command
                </p>
                <h2 class="max-w-2xl text-[34px] font-semibold leading-[1.05] tracking-[-0.055em] text-[#f7f8f8] md:text-[44px]">
                  Live field plan across 3 critical jobs.
                </h2>
              </div>
              <div class="rounded-lg border border-[#34343a] bg-[#010102] p-3 text-right">
                <p class="text-[12px] text-[#8a8f98]">Schedule confidence</p>
                <p class="mt-1 text-2xl font-semibold tracking-[-0.04em] text-[#f7f8f8]">87%</p>
              </div>
            </div>

            <div class="grid gap-3 md:grid-cols-3">
              {#each shifts as shift}
                <article class="group rounded-lg border border-[#23252a] bg-[#141516] p-3 transition hover:border-[#34343a]">
                  <div class="mb-3 flex items-start justify-between gap-3">
                    <div>
                      <p class="font-mono text-[12px] text-[#62666d]">SHIFT-{shift.code}</p>
                      <h3 class="mt-1 text-[15px] font-medium tracking-[-0.02em] text-[#f7f8f8]">
                        {shift.site}
                      </h3>
                    </div>
                    <span
                      class={`rounded-full border px-2 py-1 text-[11px] font-medium ${getStatusClass(shift.status)}`}
                    >
                      {shift.status}
                    </span>
                  </div>
                  <div class="space-y-2 text-[12px] text-[#8a8f98]">
                    <div class="flex items-center gap-2">
                      <Clock3 class="h-3.5 w-3.5 text-[#62666d]" />
                      {shift.window}
                    </div>
                    <div class="flex items-center gap-2">
                      <HardHat class="h-3.5 w-3.5 text-[#62666d]" />
                      {shift.crew}
                    </div>
                  </div>
                  <div class="mt-4">
                    <div class="mb-1 flex justify-between text-[11px] text-[#62666d]">
                      <span>Planned work</span>
                      <span>{shift.progress}%</span>
                    </div>
                    <div class="h-1.5 overflow-hidden rounded-full bg-[#23252a]">
                      <div
                        class="h-full rounded-full bg-[#5e6ad2] transition group-hover:bg-[#828fff]"
                        style={`width: ${shift.progress}%`}
                      ></div>
                    </div>
                  </div>
                </article>
              {/each}
            </div>
          </div>

          <div class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
            <div class="mb-4 flex items-center justify-between">
              <div>
                <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                  Field signal
                </p>
                <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Today at 09:42</h2>
              </div>
              <RadioTower class="h-5 w-5 text-[#5e6ad2]" />
            </div>
            <div class="rounded-lg border border-[#23252a] bg-[#010102] p-4">
              <div class="relative h-52 overflow-hidden rounded-lg border border-[#23252a] bg-[#0b0c0d]">
                <div class="map-lines"></div>
                <div class="absolute left-[16%] top-[24%] h-3 w-3 rounded-full border border-[#5e6ad2] bg-[#5e6ad2]/50 shadow-[0_0_26px_rgba(94,106,210,0.85)]"></div>
                <div class="absolute left-[63%] top-[34%] h-2.5 w-2.5 rounded-full border border-[#27a644] bg-[#27a644]/60"></div>
                <div class="absolute left-[43%] top-[68%] h-2.5 w-2.5 rounded-full border border-[#ffb06f] bg-[#ffb06f]/50"></div>
                <div class="absolute bottom-3 left-3 rounded-md border border-[#34343a] bg-[#010102]/90 px-2 py-1 text-[11px] text-[#8a8f98]">
                  18 crews · 47 assets · 6 geofences
                </div>
              </div>
              <div class="mt-3 grid grid-cols-3 gap-2 text-center">
                <div class="rounded-md bg-[#141516] p-2">
                  <p class="text-lg font-semibold tracking-[-0.04em]">96%</p>
                  <p class="text-[11px] text-[#62666d]">Checked in</p>
                </div>
                <div class="rounded-md bg-[#141516] p-2">
                  <p class="text-lg font-semibold tracking-[-0.04em]">14m</p>
                  <p class="text-[11px] text-[#62666d]">Avg lag</p>
                </div>
                <div class="rounded-md bg-[#141516] p-2">
                  <p class="text-lg font-semibold tracking-[-0.04em]">3</p>
                  <p class="text-[11px] text-[#62666d]">Exceptions</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="grid gap-4 2xl:grid-cols-[0.92fr_1.08fr]">
          <div class="grid gap-4 md:grid-cols-2">
            <article class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
              <div class="mb-4 flex items-center justify-between">
                <div>
                  <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                    Report status
                  </p>
                  <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Review queue</h2>
                </div>
                <FileText class="h-5 w-5 text-[#8a8f98]" />
              </div>
              <div class="space-y-2">
                {#each reports as report}
                  <div class="flex items-center justify-between rounded-lg border border-[#23252a] bg-[#141516] p-3">
                    <div>
                      <p class="text-[13px] font-medium text-[#f7f8f8]">{report.label}</p>
                      <p
                        class={`mt-1 text-[12px] ${
                          report.tone === 'warn'
                            ? 'text-[#ffb06f]'
                            : report.tone === 'ok'
                              ? 'text-[#72d486]'
                              : 'text-[#8a8f98]'
                        }`}
                      >
                        {report.state}
                      </p>
                    </div>
                    <p class="font-mono text-2xl tracking-[-0.05em] text-[#d0d6e0]">{report.count}</p>
                  </div>
                {/each}
              </div>
            </article>

            <article class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
              <div class="mb-4 flex items-center justify-between">
                <div>
                  <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                    Time review
                  </p>
                  <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Payroll readiness</h2>
                </div>
                <TimerReset class="h-5 w-5 text-[#8a8f98]" />
              </div>
              <div class="space-y-3">
                {#each timeRows as row}
                  <div>
                    <div class="mb-1 flex items-center justify-between gap-3">
                      <span class="text-[13px] font-medium text-[#d0d6e0]">{row.trade}</span>
                      <span class="font-mono text-[12px] text-[#8a8f98]">{row.variance}</span>
                    </div>
                    <div class="flex items-center gap-3">
                      <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-[#23252a]">
                        <div class="h-full rounded-full bg-[#5e6ad2]" style={`width: ${row.submitted}%`}></div>
                      </div>
                      <span class="w-16 text-right text-[11px] text-[#62666d]">{row.status}</span>
                    </div>
                  </div>
                {/each}
              </div>
              <button
                type="button"
                class="mt-5 flex w-full items-center justify-center gap-2 rounded-lg border border-[#34343a] bg-[#141516] px-3 py-2 text-[13px] font-medium text-[#d0d6e0] transition hover:border-[#5e6ad2]/70 hover:text-[#f7f8f8]"
              >
                Open time exceptions
                <ArrowRight class="h-4 w-4" />
              </button>
            </article>
          </div>

          <article class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
            <div class="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                  Asset state
                </p>
                <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Equipment telemetry</h2>
              </div>
              <button
                type="button"
                class="inline-flex items-center justify-center gap-2 rounded-lg border border-[#23252a] bg-[#010102] px-3 py-2 text-[13px] text-[#8a8f98] transition hover:border-[#34343a] hover:text-[#d0d6e0]"
              >
                <Gauge class="h-4 w-4" />
                Fleet health 91%
              </button>
            </div>
            <div class="overflow-hidden rounded-lg border border-[#23252a]">
              <div class="grid grid-cols-[1.35fr_0.85fr_0.7fr_1fr] border-b border-[#23252a] bg-[#141516] px-3 py-2 text-[11px] uppercase tracking-[0.18em] text-[#62666d]">
                <span>Asset</span>
                <span>Site</span>
                <span>Hours</span>
                <span>Load</span>
              </div>
              {#each assets as asset}
                <div class="grid grid-cols-[1.35fr_0.85fr_0.7fr_1fr] items-center border-b border-[#23252a] px-3 py-3 last:border-b-0">
                  <div class="min-w-0">
                    <div class="flex items-center gap-2">
                      <Truck class="h-4 w-4 shrink-0 text-[#5e6ad2]" />
                      <p class="truncate text-[13px] font-medium text-[#f7f8f8]">{asset.name}</p>
                    </div>
                    <p class="mt-1 text-[12px] text-[#62666d]">{asset.signal}</p>
                  </div>
                  <p class="text-[12px] text-[#8a8f98]">{asset.site}</p>
                  <p class="font-mono text-[12px] text-[#8a8f98]">{asset.hours}</p>
                  <div class="flex items-center gap-2">
                    <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-[#23252a]">
                      <div class="h-full rounded-full bg-[#5e6ad2]" style={`width: ${asset.load}%`}></div>
                    </div>
                    <span class="w-8 text-right font-mono text-[11px] text-[#62666d]">{asset.load}%</span>
                  </div>
                </div>
              {/each}
            </div>
          </article>
        </section>

        <section class="grid gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
          <article class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
            <div class="mb-4 flex items-center justify-between">
              <div>
                <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                  Maintenance issues
                </p>
                <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Active triage</h2>
              </div>
              <Wrench class="h-5 w-5 text-[#8a8f98]" />
            </div>
            <div class="space-y-2">
              {#each issues as issue}
                <div class="flex flex-col gap-3 rounded-lg border border-[#23252a] bg-[#141516] p-3 sm:flex-row sm:items-center sm:justify-between">
                  <div class="min-w-0">
                    <div class="mb-1 flex flex-wrap items-center gap-2">
                      <span class="font-mono text-[12px] text-[#62666d]">{issue.id}</span>
                      <span class={`rounded-full border px-2 py-0.5 text-[11px] ${getPriorityClass(issue.priority)}`}>
                        {issue.priority}
                      </span>
                    </div>
                    <p class="truncate text-[13px] font-medium text-[#f7f8f8]">{issue.title}</p>
                  </div>
                  <div class="flex items-center gap-4 text-[12px] text-[#8a8f98]">
                    <span>{issue.owner}</span>
                    <span class="font-mono">{issue.age}</span>
                  </div>
                </div>
              {/each}
            </div>
          </article>

          <article class="rounded-xl border border-[#23252a] bg-[#0f1011]/94 p-4">
            <div class="mb-4 flex items-center justify-between">
              <div>
                <p class="text-[12px] font-medium uppercase tracking-[0.22em] text-[#62666d]">
                  Closeout path
                </p>
                <h2 class="mt-1 text-[18px] font-semibold tracking-[-0.03em]">Next actions</h2>
              </div>
              <ClipboardCheck class="h-5 w-5 text-[#8a8f98]" />
            </div>
            <div class="space-y-3">
              <div class="flex gap-3">
                <CheckCircle2 class="mt-0.5 h-4 w-4 shrink-0 text-[#27a644]" />
                <div>
                  <p class="text-[13px] font-medium text-[#d0d6e0]">Approve 31 daily logs</p>
                  <p class="text-[12px] text-[#62666d]">Batch-ready with photo proof attached.</p>
                </div>
              </div>
              <div class="flex gap-3">
                <AlertTriangle class="mt-0.5 h-4 w-4 shrink-0 text-[#ffb06f]" />
                <div>
                  <p class="text-[13px] font-medium text-[#d0d6e0]">Resolve Northline blocker</p>
                  <p class="text-[12px] text-[#62666d]">Panel labeling issue is holding inspection slot.</p>
                </div>
              </div>
              <div class="flex gap-3">
                <MapPin class="mt-0.5 h-4 w-4 shrink-0 text-[#5e6ad2]" />
                <div>
                  <p class="text-[13px] font-medium text-[#d0d6e0]">Rebalance survey crew</p>
                  <p class="text-[12px] text-[#62666d]">Foundry east wing is 2.1 hours behind baseline.</p>
                </div>
              </div>
            </div>
            <div class="mt-5 rounded-lg border border-[#34343a] bg-[#010102] p-3">
              <div class="mb-2 flex items-center gap-2 text-[#d0d6e0]">
                <CalendarClock class="h-4 w-4 text-[#5e6ad2]" />
                <p class="text-[13px] font-medium">Superintendent sync</p>
              </div>
              <p class="text-[12px] leading-5 text-[#8a8f98]">
                10:15 AM · Remote and trailer B · agenda locked from open exceptions.
              </p>
            </div>
          </article>
        </section>
      </main>
    </div>
  </div>
</section>

<style>
  .linear-shell {
    position: relative;
    font-family:
      "Linear Text",
      "SF Pro Text",
      -apple-system,
      BlinkMacSystemFont,
      "Segoe UI",
      sans-serif;
  }

  .linear-shell h1,
  .linear-shell h2,
  .linear-shell h3 {
    font-family:
      "Linear Display",
      "SF Pro Display",
      -apple-system,
      BlinkMacSystemFont,
      "Segoe UI",
      sans-serif;
  }

  .grid-glow {
    position: absolute;
    inset: -1px;
    background:
      radial-gradient(circle at 50% -10%, rgba(94, 106, 210, 0.2), transparent 32%),
      linear-gradient(rgba(255, 255, 255, 0.025) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255, 255, 255, 0.025) 1px, transparent 1px);
    background-size:
      auto,
      48px 48px,
      48px 48px;
    mask-image: linear-gradient(to bottom, black, transparent 86%);
  }

  .noise-layer {
    position: absolute;
    inset: 0;
    background-image: radial-gradient(rgba(255, 255, 255, 0.055) 0.6px, transparent 0.6px);
    background-size: 3px 3px;
    opacity: 0.24;
  }

  .map-lines {
    position: absolute;
    inset: 0;
    background:
      linear-gradient(120deg, transparent 18%, rgba(94, 106, 210, 0.28) 19%, transparent 20%),
      linear-gradient(28deg, transparent 42%, rgba(255, 255, 255, 0.08) 43%, transparent 44%),
      linear-gradient(155deg, transparent 58%, rgba(255, 255, 255, 0.06) 59%, transparent 60%),
      radial-gradient(circle at 18% 25%, rgba(94, 106, 210, 0.22), transparent 18%),
      radial-gradient(circle at 65% 35%, rgba(39, 166, 68, 0.12), transparent 16%);
  }

  @media (prefers-reduced-motion: no-preference) {
    .linear-shell article,
    .linear-shell header,
    .linear-shell aside {
      animation: rise-in 520ms ease both;
    }
  }

  @keyframes rise-in {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
</style>
