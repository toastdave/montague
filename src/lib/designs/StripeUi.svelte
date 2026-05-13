<script lang="ts">
  import {
    Activity,
    ArrowUpRight,
    BadgeCheck,
    Building2,
    CalendarClock,
    ChartBar,
    ChevronDown,
    CircleAlert,
    CircleCheck,
    ClipboardCheck,
    Clock3,
    CreditCard,
    FileCheck,
    HardHat,
    Landmark,
    Layers,
    ListFilter,
    PackageCheck,
    ReceiptText,
    Search,
    ShieldCheck,
    Truck,
    UsersRound,
    WalletCards
  } from 'lucide-svelte';

  const metrics = [
    {
      label: 'Certified payroll',
      value: '$184,920.44',
      helper: '38 crews, 1,426 labor hours',
      trend: '+12.8%',
      icon: UsersRound
    },
    {
      label: 'Asset exposure',
      value: '$2.47M',
      helper: '117 rentals and owned units',
      trend: '98.4%',
      icon: Truck
    },
    {
      label: 'Invoice risk',
      value: '$73,412',
      helper: 'Needs backup before release',
      trend: '14 holds',
      icon: ReceiptText
    },
    {
      label: 'Report closeout',
      value: '92.6%',
      helper: 'Daily logs reconciled by 18:00',
      trend: '+5.1%',
      icon: ClipboardCheck
    }
  ];

  const reviewQueue = [
    {
      id: 'CO-1848',
      title: 'South crane mat redesign',
      site: 'Civic Center Station',
      amount: '$41,280',
      age: '12m',
      status: 'Needs estimator',
      accent: 'ruby'
    },
    {
      id: 'INV-7712',
      title: 'Concrete washout and standby',
      site: 'I-87 Retaining Wall',
      amount: '$18,940',
      age: '21m',
      status: 'Backup attached',
      accent: 'green'
    },
    {
      id: 'RPT-4209',
      title: 'Friday weather delay packet',
      site: 'Harbor Pump House',
      amount: '$9,600',
      age: '37m',
      status: 'Foreman signed',
      accent: 'purple'
    }
  ];

  const laborRows = [
    {
      crew: 'Earthworks A',
      foreman: 'M. Alvarez',
      hours: '384.5',
      overtime: '22.0',
      variance: '+$4,880',
      status: 'Ready'
    },
    {
      crew: 'Rebar Night',
      foreman: 'K. Ito',
      hours: '216.0',
      overtime: '41.5',
      variance: '+$11,240',
      status: 'Review'
    },
    {
      crew: 'MEP Layout',
      foreman: 'D. Nash',
      hours: '148.0',
      overtime: '0.0',
      variance: '-$1,920',
      status: 'Ready'
    },
    {
      crew: 'Traffic Control',
      foreman: 'S. Walker',
      hours: '96.5',
      overtime: '8.0',
      variance: '+$2,106',
      status: 'Hold'
    }
  ];

  const assetRows = [
    {
      asset: 'CAT 336 Excavator',
      owner: 'Sunbelt Rentals',
      unit: 'EQ-4429',
      utilization: 87,
      cost: '$8,420',
      flag: 'GPS verified'
    },
    {
      asset: 'Tower crane TC-2',
      owner: 'Owned fleet',
      unit: 'CR-019',
      utilization: 64,
      cost: '$19,880',
      flag: 'Idle exception'
    },
    {
      asset: 'Concrete pump 52m',
      owner: 'Brundage Bone',
      unit: 'PU-331',
      utilization: 91,
      cost: '$12,600',
      flag: 'Ticket matched'
    }
  ];

  const financeRows = [
    {
      type: 'Invoice',
      ref: 'INV-7712',
      vendor: 'Apex Concrete Supply',
      amount: '$84,250.00',
      confidence: '99.1%',
      state: 'Approve'
    },
    {
      type: 'Change order',
      ref: 'CO-1848',
      vendor: 'Northline Shoring',
      amount: '$41,280.00',
      confidence: '87.4%',
      state: 'Needs backup'
    },
    {
      type: 'Allowance draw',
      ref: 'ALW-099',
      vendor: 'Metro Flagging',
      amount: '$12,416.20',
      confidence: '94.8%',
      state: 'Route'
    }
  ];

  const reportFlow = [
    {
      label: 'Field log',
      detail: '37 submitted',
      progress: 100,
      state: 'Complete'
    },
    {
      label: 'Cost coding',
      detail: '4 exceptions',
      progress: 82,
      state: 'Review'
    },
    {
      label: 'Client packet',
      detail: 'Drafted 14:42',
      progress: 68,
      state: 'Assembling'
    },
    {
      label: 'ERP export',
      detail: 'Queued',
      progress: 18,
      state: 'Pending'
    }
  ];

  const ledgerEvents = [
    {
      time: '14:58',
      title: 'Subcontractor lien waiver cleared',
      detail: 'Northline Shoring • CO-1848 now eligible for executive review'
    },
    {
      time: '14:36',
      title: 'Daily report reconciled to invoice lines',
      detail: '21 material tickets matched against Apex Concrete invoice INV-7712'
    },
    {
      time: '13:51',
      title: 'Equipment standby anomaly detected',
      detail: 'Tower crane TC-2 logged 3.7 billed idle hours without lift plan activity'
    }
  ];

  const navItems = ['Work queue', 'Labor', 'Assets', 'Invoices', 'Reports'];

  const queueBadgeClass = (accent: string) => {
    const base = 'rounded-[4px] border px-1.5 py-0.5 text-[10px]';

    if (accent === 'ruby') {
      return `${base} border-[#ffd7ef] bg-[#ffd7ef]/70 text-[#ea2261]`;
    }

    if (accent === 'green') {
      return `${base} border-[rgba(21,190,83,0.35)] bg-[rgba(21,190,83,0.16)] text-[#108c3d]`;
    }

    return `${base} border-[#b9b9f9] bg-[#d6d9fc]/70 text-[#533afd]`;
  };

  const laborStatusClass = (status: string) =>
    status === 'Ready'
      ? 'rounded-[4px] border border-[rgba(21,190,83,0.4)] bg-[rgba(21,190,83,0.16)] px-1.5 py-0.5 text-[10px] text-[#108c3d]'
      : 'rounded-[4px] border border-[#ffd7ef] bg-[#ffd7ef]/60 px-1.5 py-0.5 text-[10px] text-[#ea2261]';

  const financeStateClass = (state: string) =>
    state === 'Approve'
      ? 'rounded-[4px] border border-[rgba(21,190,83,0.4)] bg-[rgba(21,190,83,0.16)] px-2 py-1 text-[11px] text-[#108c3d]'
      : 'rounded-[4px] border border-[#d6d9fc] bg-[#f6f9fc] px-2 py-1 text-[11px] text-[#533afd]';
</script>

<section class="stripe-study min-h-screen overflow-hidden bg-[#ffffff] text-[#061b31]">
  <div class="pointer-events-none absolute inset-x-0 top-0 h-[420px] overflow-hidden">
    <div
      class="absolute -right-24 top-[-190px] h-[390px] w-[760px] rotate-[-11deg] rounded-[42px] bg-[linear-gradient(115deg,#533afd_0%,#ea2261_45%,#f96bee_74%,#ffd7ef_100%)] opacity-[0.16] blur-[1px]"
    ></div>
    <div
      class="absolute left-[-260px] top-28 h-[280px] w-[640px] rotate-[-7deg] rounded-[36px] bg-[linear-gradient(110deg,#f6f9fc,#d6d9fc_58%,#ffffff)] opacity-80"
    ></div>
  </div>

  <header
    class="relative z-10 border-b border-[#e5edf5]/80 bg-white/82 backdrop-blur-xl"
  >
    <div class="mx-auto flex max-w-[1180px] items-center justify-between px-5 py-4 lg:px-8">
      <div class="flex items-center gap-8">
        <div class="flex items-center gap-3">
          <div
            class="grid h-9 w-9 place-items-center rounded-[6px] bg-[#533afd] text-white shadow-[rgba(50,50,93,0.25)_0px_18px_28px_-18px,rgba(0,0,0,0.1)_0px_10px_18px_-10px]"
          >
            <Building2 size={18} strokeWidth={2.1} />
          </div>
          <div>
            <p class="text-[15px] font-normal tracking-[-0.15px] text-[#061b31]">Montague</p>
            <p class="mono -mt-0.5 text-[9px] uppercase tracking-[0.08em] text-[#64748d]">
              Operations ledger
            </p>
          </div>
        </div>

        <nav class="hidden items-center gap-1 lg:flex">
          {#each navItems as item}
            <a
              class="rounded-[4px] px-3 py-2 text-[14px] font-normal leading-none text-[#273951] transition hover:bg-[#f6f9fc] hover:text-[#533afd]"
              href="/stripe"
            >
              {item}
            </a>
          {/each}
        </nav>
      </div>

      <div class="hidden items-center gap-3 md:flex">
        <div
          class="flex h-9 w-[230px] items-center gap-2 rounded-[4px] border border-[#e5edf5] bg-white px-3 text-[#64748d] shadow-[rgba(23,23,23,0.06)_0px_3px_6px]"
        >
          <Search size={15} />
          <span class="text-[13px]">Search cost code, vendor, report</span>
        </div>
        <button
          class="rounded-[4px] border border-[#b9b9f9] px-4 py-2 text-[14px] leading-none text-[#533afd] transition hover:bg-[#533afd]/5"
        >
          Export packet
        </button>
        <button
          class="rounded-[4px] bg-[#533afd] px-4 py-2 text-[14px] leading-none text-white shadow-[rgba(50,50,93,0.25)_0px_20px_32px_-20px,rgba(0,0,0,0.1)_0px_12px_22px_-12px] transition hover:bg-[#4434d4]"
        >
          Release batch
        </button>
      </div>
    </div>
  </header>

  <main class="relative z-10 mx-auto max-w-[1180px] px-5 pb-16 pt-10 lg:px-8 lg:pt-14">
    <section class="grid gap-8 lg:grid-cols-[0.95fr_1.65fr] lg:items-end">
      <div>
        <div
          class="mb-5 inline-flex items-center gap-2 rounded-[4px] border border-[#d6d9fc] bg-white px-2 py-1 text-[12px] text-[#533afd] shadow-[rgba(23,23,23,0.06)_0px_3px_6px]"
        >
          <Activity size={13} />
          <span>Friday closeout • live at 15:04 EDT</span>
        </div>
        <h1
          class="max-w-[620px] text-[44px] font-light leading-[1.03] tracking-[-1.18px] text-[#061b31] sm:text-[56px]"
        >
          Financial-grade review for field operations.
        </h1>
        <p class="mt-5 max-w-[560px] text-[18px] font-light leading-[1.42] text-[#64748d]">
          A Stripe-mode Montague console for validating labor, equipment, change orders,
          invoices, and field reports before money moves.
        </p>
      </div>

      <div
        class="rounded-[8px] border border-[#e5edf5] bg-white p-3 shadow-[rgba(50,50,93,0.25)_0px_30px_45px_-30px,rgba(0,0,0,0.1)_0px_18px_36px_-18px]"
      >
        <div class="rounded-[6px] bg-[#1c1e54] p-4 text-white">
          <div class="flex items-center justify-between gap-4">
            <div>
              <p class="text-[13px] text-white/64">Next settlement batch</p>
              <p class="tabular mt-1 text-[34px] font-light tracking-[-0.72px]">$328,742.18</p>
            </div>
            <div
              class="grid h-11 w-11 place-items-center rounded-[6px] bg-white/10 text-[#f96bee]"
            >
              <WalletCards size={21} />
            </div>
          </div>

          <div class="mt-5 grid grid-cols-3 gap-2">
            <div class="rounded-[4px] border border-white/10 bg-white/[0.06] p-3">
              <p class="text-[11px] text-white/52">Approved</p>
              <p class="tabular mt-1 text-[18px] text-white">$241k</p>
            </div>
            <div class="rounded-[4px] border border-white/10 bg-white/[0.06] p-3">
              <p class="text-[11px] text-white/52">Held</p>
              <p class="tabular mt-1 text-[18px] text-white">$73k</p>
            </div>
            <div class="rounded-[4px] border border-white/10 bg-white/[0.06] p-3">
              <p class="text-[11px] text-white/52">SLA</p>
              <p class="tabular mt-1 text-[18px] text-white">01:56</p>
            </div>
          </div>

          <div class="mt-5 rounded-[4px] border border-[#ffd7ef]/20 bg-[#0d253d]/50 p-3">
            <div class="mb-2 flex items-center justify-between text-[12px]">
              <span class="text-white/62">Review confidence</span>
              <span class="tabular text-[#ffd7ef]">94.8%</span>
            </div>
            <div class="h-1.5 overflow-hidden rounded-full bg-white/10">
              <div class="h-full w-[94.8%] rounded-full bg-[linear-gradient(90deg,#533afd,#f96bee)]"></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="mt-8 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      {#each metrics as metric}
        {@const Icon = metric.icon}
        <article
          class="rounded-[6px] border border-[#e5edf5] bg-white p-4 shadow-[rgba(23,23,23,0.08)_0px_15px_35px_0px]"
        >
          <div class="flex items-start justify-between gap-3">
            <div>
              <p class="text-[12px] text-[#64748d]">{metric.label}</p>
              <p class="tabular mt-2 text-[28px] font-light tracking-[-0.42px] text-[#061b31]">
                {metric.value}
              </p>
            </div>
            <div
              class="grid h-9 w-9 place-items-center rounded-[5px] border border-[#d6d9fc] bg-[#f6f9fc] text-[#533afd]"
            >
              <Icon size={17} />
            </div>
          </div>
          <div class="mt-4 flex items-center justify-between gap-3">
            <p class="text-[12px] leading-snug text-[#64748d]">{metric.helper}</p>
            <span
              class="tabular rounded-[4px] border border-[rgba(21,190,83,0.4)] bg-[rgba(21,190,83,0.16)] px-1.5 py-0.5 text-[10px] text-[#108c3d]"
            >
              {metric.trend}
            </span>
          </div>
        </article>
      {/each}
    </section>

    <section class="mt-6 grid gap-6 lg:grid-cols-[360px_1fr]">
      <aside
        class="rounded-[8px] border border-[#e5edf5] bg-white shadow-[rgba(50,50,93,0.25)_0px_30px_45px_-30px,rgba(0,0,0,0.1)_0px_18px_36px_-18px]"
      >
        <div class="flex items-center justify-between border-b border-[#e5edf5] p-4">
          <div>
            <p class="text-[18px] font-light tracking-[-0.18px]">Exception queue</p>
            <p class="mt-1 text-[12px] text-[#64748d]">Prioritized by exposure and SLA.</p>
          </div>
          <button
            class="grid h-8 w-8 place-items-center rounded-[4px] border border-[#e5edf5] text-[#533afd]"
            aria-label="Filter queue"
          >
            <ListFilter size={15} />
          </button>
        </div>

        <div class="space-y-3 p-3">
          {#each reviewQueue as item}
            <article
              class="group rounded-[6px] border border-[#e5edf5] bg-white p-3 transition hover:border-[#b9b9f9] hover:shadow-[rgba(23,23,23,0.08)_0px_15px_35px_0px]"
            >
              <div class="flex items-start justify-between gap-3">
                <div>
                  <p class="mono text-[10px] uppercase text-[#64748d]">{item.id}</p>
                  <h2 class="mt-1 text-[15px] font-normal leading-snug text-[#061b31]">
                    {item.title}
                  </h2>
                  <p class="mt-1 text-[12px] text-[#64748d]">{item.site}</p>
                </div>
                <ArrowUpRight
                  class="mt-1 text-[#b9b9f9] transition group-hover:text-[#533afd]"
                  size={15}
                />
              </div>
              <div class="mt-3 flex items-center justify-between gap-3">
                <span class="tabular text-[15px] text-[#061b31]">{item.amount}</span>
                <span class="tabular text-[11px] text-[#64748d]">{item.age} waiting</span>
              </div>
              <div class="mt-3 flex items-center justify-between gap-3">
                <span class={queueBadgeClass(item.accent)}>
                  {item.status}
                </span>
                <button class="text-[12px] text-[#533afd]">Open review</button>
              </div>
            </article>
          {/each}
        </div>
      </aside>

      <div class="space-y-6">
        <section
          class="rounded-[8px] border border-[#e5edf5] bg-white shadow-[rgba(23,23,23,0.08)_0px_15px_35px_0px]"
        >
          <div class="flex flex-col gap-3 border-b border-[#e5edf5] p-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p class="text-[22px] font-light tracking-[-0.22px]">Labor verification</p>
              <p class="mt-1 text-[12px] text-[#64748d]">
                Payroll lines compared to daily reports, geofence pings, and budgeted production.
              </p>
            </div>
            <button
              class="inline-flex items-center gap-2 rounded-[4px] border border-[#d6d9fc] px-3 py-2 text-[13px] text-[#533afd]"
            >
              <ShieldCheck size={14} />
              Audit rules
            </button>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full min-w-[690px] text-left">
              <thead>
                <tr class="border-b border-[#e5edf5] text-[11px] uppercase tracking-[0.04em] text-[#64748d]">
                  <th class="px-4 py-3 font-normal">Crew</th>
                  <th class="px-4 py-3 font-normal">Foreman</th>
                  <th class="px-4 py-3 font-normal">Hours</th>
                  <th class="px-4 py-3 font-normal">OT</th>
                  <th class="px-4 py-3 font-normal">Budget variance</th>
                  <th class="px-4 py-3 font-normal">State</th>
                </tr>
              </thead>
              <tbody>
                {#each laborRows as row}
                  <tr class="border-b border-[#f6f9fc] last:border-0">
                    <td class="px-4 py-3">
                      <div class="flex items-center gap-2">
                        <div
                          class="grid h-7 w-7 place-items-center rounded-[4px] bg-[#f6f9fc] text-[#533afd]"
                        >
                          <HardHat size={14} />
                        </div>
                        <span class="text-[13px] text-[#061b31]">{row.crew}</span>
                      </div>
                    </td>
                    <td class="px-4 py-3 text-[13px] text-[#273951]">{row.foreman}</td>
                    <td class="tabular px-4 py-3 text-[13px] text-[#061b31]">{row.hours}</td>
                    <td class="tabular px-4 py-3 text-[13px] text-[#061b31]">{row.overtime}</td>
                    <td
                      class:positive={row.variance.startsWith('+')}
                      class:negative={row.variance.startsWith('-')}
                      class="tabular px-4 py-3 text-[13px]"
                    >
                      {row.variance}
                    </td>
                    <td class="px-4 py-3">
                      <span class={laborStatusClass(row.status)}>
                        {row.status}
                      </span>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </section>

        <div class="grid gap-6 xl:grid-cols-[1fr_340px]">
          <section
            class="rounded-[8px] border border-[#e5edf5] bg-white p-4 shadow-[rgba(23,23,23,0.08)_0px_15px_35px_0px]"
          >
            <div class="flex items-center justify-between gap-4">
              <div>
                <p class="text-[22px] font-light tracking-[-0.22px]">Assets and utilization</p>
                <p class="mt-1 text-[12px] text-[#64748d]">Rental exposure reconciled to site telemetry.</p>
              </div>
              <Truck size={18} class="text-[#533afd]" />
            </div>

            <div class="mt-4 space-y-3">
              {#each assetRows as row}
                <div class="rounded-[6px] border border-[#e5edf5] p-3">
                  <div class="flex items-start justify-between gap-3">
                    <div>
                      <p class="text-[13px] text-[#061b31]">{row.asset}</p>
                      <p class="mt-0.5 text-[11px] text-[#64748d]">
                        {row.owner} • {row.unit}
                      </p>
                    </div>
                    <span class="tabular text-[13px] text-[#061b31]">{row.cost}</span>
                  </div>
                  <div class="mt-3 flex items-center gap-3">
                    <div class="h-1.5 flex-1 overflow-hidden rounded-full bg-[#f6f9fc]">
                      <div
                        class="h-full rounded-full bg-[linear-gradient(90deg,#533afd,#665efd)]"
                        style={`width: ${row.utilization}%`}
                      ></div>
                    </div>
                    <span class="tabular w-10 text-right text-[11px] text-[#64748d]">
                      {row.utilization}%
                    </span>
                  </div>
                  <p class="mt-2 text-[11px] text-[#533afd]">{row.flag}</p>
                </div>
              {/each}
            </div>
          </section>

          <section
            class="rounded-[8px] border border-[#061b31] bg-[#0d253d] p-4 text-white shadow-[rgba(3,3,39,0.25)_0px_14px_21px_-14px,rgba(0,0,0,0.1)_0px_8px_17px_-8px]"
          >
            <div class="flex items-center justify-between">
              <div>
                <p class="text-[20px] font-light tracking-[-0.2px]">Report flow</p>
                <p class="mt-1 text-[12px] text-white/54">Closeout packet readiness</p>
              </div>
              <FileCheck size={18} class="text-[#f96bee]" />
            </div>

            <div class="mt-5 space-y-4">
              {#each reportFlow as stage}
                <div>
                  <div class="mb-2 flex items-center justify-between gap-3">
                    <div>
                      <p class="text-[13px] text-white">{stage.label}</p>
                      <p class="text-[11px] text-white/48">{stage.detail}</p>
                    </div>
                    <span class="text-[11px] text-[#ffd7ef]">{stage.state}</span>
                  </div>
                  <div class="h-1.5 overflow-hidden rounded-full bg-white/10">
                    <div
                      class="h-full rounded-full bg-[linear-gradient(90deg,#ea2261,#f96bee)]"
                      style={`width: ${stage.progress}%`}
                    ></div>
                  </div>
                </div>
              {/each}
            </div>
          </section>
        </div>
      </div>
    </section>

    <section class="mt-6 grid gap-6 lg:grid-cols-[1fr_390px]">
      <section
        class="rounded-[8px] border border-[#e5edf5] bg-white shadow-[rgba(50,50,93,0.25)_0px_30px_45px_-30px,rgba(0,0,0,0.1)_0px_18px_36px_-18px]"
      >
        <div class="flex flex-col gap-3 border-b border-[#e5edf5] p-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p class="text-[22px] font-light tracking-[-0.22px]">Invoices and change orders</p>
            <p class="mt-1 text-[12px] text-[#64748d]">Payment review with confidence, backup, and routing state.</p>
          </div>
          <div class="flex items-center gap-2">
            <button
              class="inline-flex items-center gap-2 rounded-[4px] border border-[#e5edf5] px-3 py-2 text-[13px] text-[#273951]"
            >
              May period
              <ChevronDown size={13} />
            </button>
            <button
              class="rounded-[4px] bg-[#533afd] px-3 py-2 text-[13px] leading-none text-white"
            >
              Route selected
            </button>
          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full min-w-[740px] text-left">
            <thead>
              <tr class="border-b border-[#e5edf5] text-[11px] uppercase tracking-[0.04em] text-[#64748d]">
                <th class="px-4 py-3 font-normal">Type</th>
                <th class="px-4 py-3 font-normal">Reference</th>
                <th class="px-4 py-3 font-normal">Vendor</th>
                <th class="px-4 py-3 font-normal">Amount</th>
                <th class="px-4 py-3 font-normal">Confidence</th>
                <th class="px-4 py-3 font-normal">Action</th>
              </tr>
            </thead>
            <tbody>
              {#each financeRows as row}
                <tr class="border-b border-[#f6f9fc] last:border-0">
                  <td class="px-4 py-3">
                    <div class="flex items-center gap-2 text-[13px] text-[#061b31]">
                      {#if row.type === 'Invoice'}
                        <CreditCard size={14} class="text-[#533afd]" />
                      {:else if row.type === 'Change order'}
                        <Layers size={14} class="text-[#ea2261]" />
                      {:else}
                        <Landmark size={14} class="text-[#9b6829]" />
                      {/if}
                      {row.type}
                    </div>
                  </td>
                  <td class="mono px-4 py-3 text-[11px] text-[#64748d]">{row.ref}</td>
                  <td class="px-4 py-3 text-[13px] text-[#273951]">{row.vendor}</td>
                  <td class="tabular px-4 py-3 text-[13px] text-[#061b31]">{row.amount}</td>
                  <td class="tabular px-4 py-3 text-[13px] text-[#061b31]">{row.confidence}</td>
                  <td class="px-4 py-3">
                    <span class={financeStateClass(row.state)}>
                      {row.state}
                    </span>
                  </td>
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </section>

      <aside
        class="rounded-[8px] border border-[#e5edf5] bg-white p-4 shadow-[rgba(23,23,23,0.08)_0px_15px_35px_0px]"
      >
        <div class="flex items-start justify-between gap-4">
          <div>
            <p class="text-[22px] font-light tracking-[-0.22px]">Ledger activity</p>
            <p class="mt-1 text-[12px] text-[#64748d]">Immutable review trail for today.</p>
          </div>
          <ChartBar size={18} class="text-[#533afd]" />
        </div>

        <div class="mt-5 space-y-4">
          {#each ledgerEvents as event, index}
            <div class="relative pl-8">
              {#if index !== ledgerEvents.length - 1}
                <div class="absolute left-[9px] top-5 h-[calc(100%+16px)] w-px bg-[#e5edf5]"></div>
              {/if}
              <div
                class="absolute left-0 top-0 grid h-5 w-5 place-items-center rounded-full border border-[#d6d9fc] bg-white text-[#533afd]"
              >
                {#if index === 0}
                  <CircleCheck size={12} />
                {:else if index === 1}
                  <BadgeCheck size={12} />
                {:else}
                  <CircleAlert size={12} />
                {/if}
              </div>
              <p class="tabular text-[10px] text-[#64748d]">{event.time}</p>
              <p class="mt-1 text-[13px] leading-snug text-[#061b31]">{event.title}</p>
              <p class="mt-1 text-[12px] leading-snug text-[#64748d]">{event.detail}</p>
            </div>
          {/each}
        </div>

        <div
          class="mt-6 rounded-[6px] border border-dashed border-[#362baa] bg-[#f6f9fc] p-4"
        >
          <div class="flex items-center gap-2 text-[#533afd]">
            <CalendarClock size={15} />
            <p class="text-[13px]">Controller signoff due in 01:56</p>
          </div>
          <p class="mt-2 text-[12px] leading-snug text-[#64748d]">
            Two change order backups and one idle-equipment exception block automatic release.
          </p>
        </div>
      </aside>
    </section>
  </main>
</section>

<style>
  .stripe-study {
    --stripe-heading: #061b31;
    --stripe-body: #64748d;
    font-family:
      sohne-var,
      'SF Pro Display',
      'Helvetica Neue',
      Arial,
      sans-serif;
    font-feature-settings: 'ss01' on;
    letter-spacing: -0.01em;
  }

  .stripe-study :global(button),
  .stripe-study :global(a) {
    font-feature-settings: 'ss01' on;
  }

  .mono {
    font-family:
      SourceCodePro,
      'SFMono-Regular',
      Consolas,
      monospace;
    font-feature-settings: normal;
    letter-spacing: 0.02em;
  }

  .tabular {
    font-feature-settings: 'tnum' on;
    letter-spacing: -0.03em;
  }

  .positive {
    color: #108c3d;
  }

  .negative {
    color: #9b6829;
  }
</style>
