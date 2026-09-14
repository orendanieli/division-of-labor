# Onboarding & Handover Guide

> **Purpose.** This is the single document a new research assistant should read to take
> over all work on this project. It covers the research question and design, the data and
> its licensing, the code and conventions, the current outputs, and the working setups
> (git, Overleaf, the remote desktop where licensed data is run, and Claude Code).
>
> **Companion files.** `CLAUDE.md` and `AGENTS.md` (repo root) are the agent-facing
> versions of much of this — they tell Claude Code / Codex how to behave in this repo.
> This guide is the human-facing version and is broader. Where they overlap, all three
> should agree; if you change the pipeline, update them together.
>
> **Questions are always welcome.** Itay, Oren, and Analia ([§16](#sec-16)) will guide you on the
> research side day to day. I (Ori) won't be there in person, but I'm glad to answer
> anything by email — `ori.shoham1@gmail.com` or `orins@mit.edu` — whenever it comes up,
> especially the more technical questions: I built the codebase and did
> all the data/coding work so far, so I'm usually the fastest route to an answer there
> (and of course your favorite AI who will understand the repo much better than I do very 
> quickly).

---

## Table of contents

- [0. Read this first](#sec-0)
- [1. Project overview — research question, data, and design](#sec-1)
- [2. UKHLS data in detail](#sec-2)
- [3. The codebase in one paragraph](#sec-3)
- [4. Repository tour](#sec-4)
- [5. Run scripts and flags in detail](#sec-5)
- [6. UKHLS variables we use and how we process them](#sec-6)
- [7. Data & licensing (full walkthrough)](#sec-7)
- [8. Project administration & onboarding paperwork](#sec-8)
- [9. Running the code (the secure remote desktop for SL work)](#sec-9)
- [10. Code & coding conventions](#sec-10)
- [11. Current outputs & where they're consumed](#sec-11)
- [12. Git workflow (from scratch)](#sec-12)
- [13. Overleaf workflow (writing ↔ git)](#sec-13)
- [14. AI coding tools](#sec-14)
- [15. Where things stand & open project-level next steps](#sec-15)
- [16. Contacts, resources & glossary](#sec-16)

---

<a id="sec-0"></a>

## 0. Read this first 

If you do nothing else, read these in order:

1. This section, then **[§1](#sec-1) (project overview)** in full — research question, data, and
   design, in that order — so you know *what* we are doing, on *what data*, and *why*.
2. **[§7](#sec-7) (data & licensing)** and **[§8](#sec-8) (paperwork)** — so you understand what you may and
   may not do with the data, and what you must sign **before** touching it.
3. **[§4](#sec-4) (repo tour)** + **[§9](#sec-9) (how to run the code)** — so you can orient in the codebase.
4. Skim **[§10](#sec-10) (conventions)**, **[§12](#sec-12)–[§13](#sec-13) (git/Overleaf)**, **[§14](#sec-14) (Claude Code)**.

**Do this before touching any licensed data** (full steps in [§8](#sec-8)):

- Get added to the Special Licence as an additional researcher, wait for **UK Data
  Service approval**, sign the Special Licence User Agreement, and read the
  data-handling/security guide.
- Only then request access to the Special Licence (SL) secure machine.

**For EUL work — the only tier we currently have access to ([§7.1](#sec-7-1)) — once you're an
approved project member:**

- Get added to the team's shared Dropbox project folder — the EUL data syncs there
  automatically, no UKDS download needed ([§7.2](#sec-7-2)).
- **Before running any code**, add your own username branch to `code/lib/config.R` and
  confirm it worked with `source("code/run/00_check_inputs.R")` ([§7.4](#sec-7-4)).

**The two rules that matter most** — note the two licence tiers are governed differently
(see [§7.5](#sec-7-5) for the full version):

- **Special Licence (SL) data** — the detailed SIC/SOC and Local Authority data — may
  **only** be stored and processed on the approved secure machine ([§9](#sec-9)). It never touches a
  personal laptop, Dropbox, email, or an AI tool.
- **End User Licence (EUL) data** may live in your normal Dropbox-synced project folder and
  on a personal laptop — that's allowed by the licence. The constraint on EUL data is
  narrower but still absolute: **it must never be readable by an AI coding tool** (Claude
  Code, Codex, ChatGPT, etc.). In practice that means keeping the EUL raw/derived data
  folder **out of the sync scope of whatever machine you run AI tools on** — see [§14](#sec-14) for how
  this is actually set up.

---

<a id="sec-1"></a>

## 1. Project overview — research question, data, and design

*Drafted from the Special Licence project application
(`data_agreements/submit/SpecialLicenceProjectApplication_revised.pdf`), the event-study
equation and reading guide in `couples_graphs.tex` / `couples_graphs_short.tex`, `CLAUDE.md`,
`method.tex`, and the two grant proposals under `grants/`.*

<a id="sec-1-1"></a>

### 1.1 Research question and the COVID natural experiment

**The question.** Gender gaps in earnings and careers are tightly linked to how couples
divide *paid* and *unpaid* work, especially after children arrive. This project asks
whether a **temporary, externally-imposed shock to household work allocation** — caused by
COVID-19 — **durably changed the division of labour within couples**, and whether that fed
through to gender gaps in labour-market outcomes and career trajectories. The focus is on
**co-resident couples, especially couples with dependent children** observed before the
pandemic.

**Why COVID is the experiment.** The pandemic forced sharp, externally-driven variation
across households depending on each partner's **pre-pandemic industry and occupation**:
some parents kept working outside the home (key workers), some shifted to home working,
others were shut down or furloughed. Think of a couple where the mother is a nurse who
keeps working at the hospital while her gym-instructor husband stays home. The unforeseen
nature of the pandemic, its differential effect on people depending on their
pre-determined work characteristics, combined with the fact that **local** restrictions
varied over time and place, gives credible quasi-experimental variation in how much time
each partner had to spend at home.

<a id="sec-1-2"></a>

### 1.2 Two legs of the project: Israel administrative data and UKHLS

The project currently has **two legs** using the same underlying research
question, run on different data:

- **An Israel administrative-data leg.** Uses Israeli administrative data form the
Central Bureau of Statistics (למ"ס).
- **The UKHLS leg — what this repo implements.** Uses UK Understanding Society survey data with the same underlying logic (pre-pandemic industry/occupation
  exposure → COVID-era division-of-labour outcomes). While smaller in sample it
  allows more detailed analysis of time use which is critical to understanding
  changes in household divison of labor and home production. **Everything else in this guide, and
  essentially all the code in `code/`, is this leg.**

Some project documents (`method.tex`, the Falk/Sapir proposals under `grants/`) also sketch a
broader **cross-country** ambition that additionally mentions German survey data. That is
framing/future work, not implemented anywhere in this repo.

<a id="sec-1-3"></a>

### 1.3 Data: Understanding Society (UKHLS)

This project uses the UK Household Longitudinal Study (**Understanding Society**, UKHLS), a
large, nationally representative panel that has followed the same UK households annually
since 2009, collecting detailed employment, income, education, health, and family
information for every household member.

We draw on **two linked UKHLS instruments**: the regular **main survey** — the core, ongoing
annual interview — and a short, separate **COVID-19 Study** fielded to the same panel
members at a much higher frequency specifically during the pandemic (2020–2021). Because
both instruments follow the same individuals, and link partners within a household to one
another, we can observe the same couples before, during, and after COVID.

Concretely, we use the person/household identifiers that link spouses to each other to
construct a **panel of couples**: for each couple we require both partners to be observed,
employed, and assigned a known **pre-pandemic industry and occupation** in the main survey
before COVID, and we then follow that couple through the COVID survey and into later
main-survey waves. This pre-pandemic industry/occupation pairing is exactly what feeds the
exposure classification and treatment/instrument construction in [§1.4](#sec-1-4) below.

The operational detail behind this — wave letters, calendar mapping, file types, and how the
identifiers and variable naming actually work in the code — is covered separately in [§2](#sec-2)
("UKHLS data in detail"). You don't need it to follow the design in [§1.4](#sec-1-4), but read it before
touching the data pipeline.

---

<a id="sec-1-4"></a>

### 1.4 Empirical design: treatment, instrument, and equations

**Pre-pandemic exposure classification (the shared building block for both designs
below).** Using each partner's pre-COVID **SIC** (industry) and **SOC** (occupation)
codes, plus the Office of National Statistics (ONS) key-worker classification and the
IFS shutdown-sector classification (Joyce & Xu 2020), jobs are sorted into exposure groups —
key-worker sectors, shutdown sectors, and later we may consider classifying high/low capacity to work
from home. This classification is built only from pre-pandemic information, so it is not
contaminated by post-shock choices. Importantly, it plays **two different roles** depending
on the empirical design (§ "Two empirical steps"
below): it defines the **treatment groups** in the event-study design, and it is part of
the **excluded instrument** in the IV design. The two headline couple-level
exposure contrasts are:

1. **Wife is a key worker in a non-education sector**, while the **husband is not a key
   worker (or is education-only)**.
2. **Husband is in a shutdown sector**, while the **wife is not** (with symmetric
   husband/wife variants).

**Two empirical steps.**

#### Step 1 — Descriptive + event study (the part the code currently implements most fully)

Here the exposure contrasts above are used directly **as the treatment**. Event studies are
estimated separately by study sample (COVID waves / main-study waves), treatment definition,
spouse, outcome, and baseline child-age group (youngest child 0–10 vs. 11–17). This is
exactly the specification in the slide decks' "Event-study methodology" frame
(`couples_graphs.tex`, `couples_graphs_short.tex`) and in
`code/lib/event_study_regressions.R` (`build_event_study_formula()`,
estimated with `fixest::feols`):

$$
Y_{ict} \;=\; \alpha_t \;+\; \delta T_c \;+\;
\sum_{\tau \neq \tau_0} \beta_{\tau}\Big[\mathbf{1}\{t=\tau\}\times T_c\Big]
\;+\; X_c'\gamma \;+\; \varepsilon_{ict}
$$

where:
- $i$ indexes the person (wife or husband, estimated in **separate regressions by spouse**),
  $c$ the couple, $t$ calendar time (event time in the code).
- $T_c$ is the **couple-level treatment indicator** (one of the two exposure contrasts above,
  e.g. wife-key-worker/husband-not).
- $\alpha_t$ are period fixed effects; $\tau_0$ is the **omitted reference period** — 2019 for
  main-study event studies, 2019 where available for COVID-study event studies (else
  Jan–Feb 2020 for WFH/work-outside outcomes).
- $\beta_\tau$ are the coefficients of interest: the treatment-vs-comparison gap in event
  time $\tau$, relative to $\tau_0$. Pre-period $\beta_\tau$'s near zero support the
  pre-trends/parallel-trends assumption.
- $X_c'\gamma$ are baseline covariates: wife/husband age, wife/husband education category,
  number of children under 18, number of children under 10, and region.
- $\delta$ (the level term on $T_c$) is dropped and replaced by **couple fixed effects** in
  the couple-FE specification (`MAKE_EVENT_STUDIES_COUPLE_FE` in `config.R`); standard errors
  are clustered at the person level in all specifications.

Outcomes include employment, work hours, wages, work location, housework hours, childcare
hours/responsibility, selected health/well-being, and family events (divorces, childbirths).
Heterogeneity by **age of youngest child** at onset is a key cut (run as separate regressions
by child-age group, not an interaction term, in the current code).

#### Step 2 — Instrumental-variables design (planned for future work)

**This design is not yet built in `code/`** — see the end of this subsection for exactly
what's still missing. The equations below describe the intended specification, not
something you can currently run. Here the couple's ***realised*** work-location
configuration during COVID — the joint state
of wife's and husband's at-home/working-outside status, e.g. (wife home, husband home),
(wife home, husband out), (wife out, husband home), (wife out, husband out) — is treated as
**endogenous** (parents may select into WFH, reduce hours, or leave employment in response to
household needs). It is instrumented using the **same pre-pandemic exposure classification**
from Step 1 — not as a treatment here, but as (part of) the **excluded instrument** —
interacted with **local** COVID restrictions at Local Authority District level. Per the
Special Licence application (§2.2), the two-stage design is:

**First stage** (one regression per realised state $s$):

$$
D_{c,s} \;=\; \pi_s' Z_c \;+\; \rho_s R_{\ell(c)} \;+\; \theta_s'\big(Z_c \times R_{\ell(c)}\big)
\;+\; X_c'\Gamma_s \;+\; \eta_{c,s}
$$

**Second stage:**

$$
Y_{ict} \;=\; \sum_{s} \lambda_{s,i}\, \widehat{D}_{c,s} \;+\; \psi_t \;+\; X_c'\kappa
\;+\; \varepsilon_{ict}
$$

where:
- $D_{c,s}$ is an indicator that couple $c$ is in realised state $s$ during the COVID period.
- $Z_c$ is the vector of **pre-pandemic predicted exposure** for both partners — predicted
  key-worker status, predicted shutdown-sector exposure, and predicted capacity to work from
  home, for wife and husband separately. This is the same underlying SIC/SOC-based
  classification as Step 1, just used here as instrument components rather than as treatment.
- $R_{\ell(c)}$ is the local-restriction intensity (school closures, workplace/social
  restrictions) in couple $c$'s Local Authority District $\ell(c)$ at the time of interview —
  requires the Special-Licence LAD identifiers ([§7.1](#sec-7-1)) and the IFS restrictions linkage
  (see "Data linkage" below).
- $Z_c \times R_{\ell(c)}$ lets the same pre-pandemic job imply different realised
  work-location outcomes depending on how binding local restrictions were at the time.
- $\lambda_{s,i}$ (second stage) is the causal effect of interest: how each realised
  couple work-location configuration affects spouse $i$'s outcomes.
- Couple fixed effects can be added to both stages where not collinear with the excluded
  instruments; $X_c$ denotes the corresponding controls vector in each stage.

As flagged above, this design is not yet built; the SL Local Authority data (SN 6666) and
the IFS restrictions linkage need to be wired in first (see [§15](#sec-15)).

**Data linkage.** Local Authority District identifiers (Special Licence only) link
households to the **IFS COVID-19 Restrictions Dataset** (school closures, workplace/social
restrictions over time) — see `policies/` for the in-repo copies and crosswalks.

**Key references** (from the application): Goldin (2014); Kleven, Landais, Posch, Steinhauer
& Zweimüller (2019); Hupkau & Petrongolo (2020); Sevilla & Smith (2020); ONS key-worker
reference tables (2020); Joyce & Xu, IFS BN278 (2020).

---

<a id="sec-2"></a>

## 2. UKHLS data in detail

This section covers the operational details behind the two UKHLS instruments introduced in
[§1.3](#sec-1-3) — waves, files, identifiers, and how the analytic panel is actually threaded together
in the code. None of this is required to follow the research design in [§1.4](#sec-1-4); come back to it
once you start working with the data pipeline.

<a id="sec-2-1"></a>

### 2.1 The two data collections, in detail

This project draws on **two separate UKHLS instruments** that happen to share the same
underlying panel members but run on completely different schedules and questionnaires:

| | **Main survey ("main study")** | **COVID-19 Study ("COVID survey")** |
|---|---|---|
| What it is | The regular, ongoing UKHLS annual interview — the core survey | A short, separate survey fielded rapidly to the *same* panel members specifically because of the pandemic, mainly online but with a telephone-mode top-up in some waves (see [§2.3](#sec-2-3)) |
| Wave naming | Lettered waves, one fieldwork round per letter: `a, b, c, … o` (each round's fieldwork spans roughly two calendar years, so a wave isn't a single instant) | Lettered `ca`–`ci` (nine rounds) |
| Cadence | Roughly annual, ongoing since 2009 | Monthly at first (April–July 2020), then roughly every 2 months through September 2021 |
| Content | Comprehensive: employment, income, education, health, housing, relationships, time use, etc. | Narrow and COVID-specific: work status, working from home, furlough, childcare, health/well-being during the pandemic |
| Analysis time unit | Primarily **calendar year of interview** (`study = "main"`); a **monthly** version also exists (`study = "main_monthly"`) but suffers from power issues — relatively few people are interviewed in any given month, so monthly event-time estimates are noisy | **Wave** (`study = "covid"`) — each COVID wave is treated as its own period, since waves are irregularly spaced calendar months rather than a regular monthly grid |
| Study number | SN 6614 (EUL) / SN 6931 (SL) | SN 8644 (same under either licence, see [§7.1](#sec-7-1)) |
| Relevant code | `code/lib/family_baseline.R`, `code/lib/history.R`, `code/lib/future_outcomes.R` | `code/lib/covid_loader.R`, `code/lib/covid_panel.R` |

The **wave-letter ↔ calendar mapping actually used in this repo** (from
`code/lib/wave_labels.R`, the single source of truth):

- **Main survey:** `a`=Wave 1 … `h`=Wave 8, **`i`=Wave 9, `j`=Wave 10, `k`=Wave 11** (the
  three candidate **baseline** waves — see [§2.2](#sec-2-2)), `l`=Wave 12, `m`=Wave 13, `n`=Wave 14,
  `o`=Wave 15.
- **COVID survey:** `ca`=Apr 2020, `cb`=May 2020, `cc`=Jun 2020, `cd`=Jul 2020,
  `ce`=Sep 2020, `cf`=Nov 2020, `cg`=Jan 2021, `ch`=Mar 2021, `ci`=Sep 2021.

Because these are two different questionnaires on two different schedules, the code always
tracks which "study" a panel came from (`study = "main"` vs. `"covid"` vs. `"main_monthly"`
in `code/lib/event_study_regressions.R`) — event time is measured in **calendar years** for
the main survey but in **irregular calendar months** for the COVID survey, and the two are
never silently pooled.

<a id="sec-2-2"></a>

### 2.2 How this project threads the two together

- **Baseline (pre-COVID) information** — both partners' industry/occupation, age,
  education, children, region — is built from the **main survey**, restricted to
  interviews that actually took place **in 2019**. Waves **I/J/K (Waves 9/10/11)** are the
  only main-study waves whose ~2-year fieldwork window overlaps 2019 at all, so they're the
  only candidates; within that, each person's baseline is their **latest** wave (K over J
  over I) among whichever of I/J/K happened to interview them in 2019 specifically — not
  simply "their most recent interview regardless of year." A wave-K interview that actually
  took place in 2018 (fieldwork windows straddle calendar years) is not used as someone's
  baseline; that person is currently just outside the baseline sample. See [§5.1](#sec-5-1)'s
  `01_build_data.R` row and [§2.4](#sec-2-4) for how this plays out downstream, and the note below on
  the 2018-fallback exploration.
- **Pre-baseline history** (waves `a`–`k`) is used for pre-trend checks and longer-run
  controls.
- **What happened *during* the pandemic** — work status, WFH, furlough, childcare, in
  April 2020 through September 2021 — comes from the **COVID survey** (`ca`–`ci`).
- **What happened *after* the pandemic** — later employment, pay, family outcomes — comes
  from **main-survey follow-up waves `j`–`o`**. The main version currently restricts to
  people/couples also observed in the COVID sample (`code/lib/future_outcomes.R`). We had
  some troubles with things looking different in the main survey vs. the COVID sample
  results in the periods where they overlap.

**Exploration: expanding the baseline with a 2018 fallback.** Because the production
baseline is 2019-only, anyone whose I/J/K interview fell in 2018 instead (or who wasn't
employed/valid in 2019) is currently excluded — this exploration asks how many additional
couples would be recovered by allowing **2018 as a fallback year**. The rule under test:
use 2019 if both spouses are observed, employed, and have valid SIC *and* SOC that year;
otherwise fall back to 2018 if both qualify there; within a year, still prefer the latest
available wave (`k > j > i > h`; waves `h`/`i`/`j` are the 2018 candidates, `i`/`j`/`k` the
2019 ones). This is exploratory, not yet the production baseline.

- **Script:** `code/explore_baseline_year_2018_2019.R` (top-level `code/`, not
  `code/run/` — it's exploratory, not part of the staged pipeline).
- **Results:** already integrated into `couples_graphs_short.tex`'s
  "Appendix: 2018 baseline fallback" section — a design slide, an observation-gain figure,
  and side-by-side couple counts (2019-only vs. 2018–2019 combined) for both the COVID
  waves and the main-study years. The figures live under
  `figures/explore/baseline_year_check/` (the `\blcdir` macro in the `.tex`).

<a id="sec-2-3"></a>

### 2.3 File types per wave and identifiers

Each main-survey wave ships as (at least) three Stata files, and the COVID survey ships one
required file (`00_check_inputs.R` looks for exactly these):

- `{w}_indresp.dta` — **individual response**: one row per person interviewed that wave;
  most substantive variables (job, income, health, attitudes) live here.
- `{w}_egoalt.dta` — **ego–alter file**: relationship links between household members (who
  is whose spouse/partner/child) — this is what lets the pipeline pair up wife/husband rows
  into couple-level records.
- `{w}_indall.dta` — **individual all**: a fuller household roster (includes people who
  weren't interviewed that wave but are still household members), used to keep track of
  household composition.
- `{cw}_indresp_w.dta` — the COVID survey's individual response file for wave `cw`,
  **web-mode** respondents. This is the **only** COVID file `00_check_inputs.R` requires and
  the only one `code/lib/covid_loader.R` loads.
- `{cw}_indresp_t.dta` — a **telephone-mode** counterpart that also exists on disk for
  **two of the nine COVID waves**. It adds only **~3–5% more observations** on the
  waves where it exists. **`00_check_inputs.R` does not check for it, and the pipeline does
  not load or merge it** — it is not part of the required-inputs checklist at all, so its
  absence never blocks the pre-flight check. This was a deliberate call, not an oversight:
  the observation gain is too small to justify the extra cleaning/harmonization effort of
  merging a differently-fielded mode into the panel.

Person-level records are keyed by `pidp` (a person identifier stable across waves and
across the main/COVID surveys — the same `pidp` links a person's main-survey and
COVID-survey rows). Couple-level files are built by joining each person's row to their
partner's row (via the `egoalt` links) and keeping both spouses' variables side by side,
usually suffixed `_w` (wife) / `_h` (husband) — you'll see this suffix convention throughout
`code/lib/`.

<a id="sec-2-4"></a>

### 2.4 Datasets and samples built by the pipeline

`code/run/01_build_data.R` is the single script that turns the raw wave files into
everything downstream. It writes to two separate output roots ([§7.4](#sec-7-4)), and the distinction
between them matters:

- **`derived/`** (`der_path`) — every intermediate and full-population dataset the pipeline
  produces along the way. Not restricted to any particular analytic sample; other scripts
  read from here when they need a fuller population than the curated samples provide.
- **`samples/`** (`samples_path`) — the curated, ready-to-analyze **analytic samples**
  (prefixed `s2019_*`) that downstream figures/tables/regressions actually use. These are
  built *from* the `derived/` files by applying the sample restrictions described below.

#### The baseline restriction that underlies (almost) everything

`build_baseline()` (`code/lib/family_baseline.R`) builds one row per person from the I/J/K
main-survey waves, preferring wave K restricted to 2019 and back-filling from J then I for
anyone missing at K — this is `baseline.rds` in `derived/`. Every downstream dataset then
starts from the **analytic baseline restriction**: baseline `jbstat` (labour-market status)
in `{1, 2}`, i.e. **employed or self-employed at baseline**. This restriction is applied
once (`df_baseline_analytic` in the build script) and threaded through nearly every dataset
described below — it is *not* re-derived independently in each one. Baseline SIC/SOC are
**not** required to be non-missing at this stage; missing/invalid codes are flagged by
`add_baseline_work_groups()` and only excluded where a specific analysis needs it.

#### Person-level datasets and samples

- `prebaseline_history_long.rds` / `_summary.rds` — each baseline-analytic person's
  observations in **main-survey waves before their own baseline wave** (long panel + a
  compact per-person summary), used for pre-trend checks and history-based controls.
- `df_sample_long_covid.rds` — the full **person × COVID-wave** panel (`ca`–`ci`) for
  baseline-analytic people, built from the merged COVID waves (`covid_all_wide.rds`) by
  `build_covid_long_panel()` (`code/lib/covid_panel.R`). Building this panel also **adds two
  synthetic pre-pandemic rows per person**: `wave == "2019"` (from the main-survey baseline)
  and `wave == "baseline"` (from a Jan–Feb-2020 recall question that UKHLS actually repeated
  across several early COVID waves — each person's **earliest valid answer, in wave order**,
  is the one used) — so the panel has a usable pre-period before the real `ca`–`ci` waves
  start; see [§6.7](#sec-6-7) for exactly how each is constructed, how the repeated-recall answers are
  prioritized, and why there are two.
- `future_outcomes_long_lmo.rds` (+ `_monthly` variant) — the **person × main-survey
  follow-up wave** panel (waves `l`–`o`), restricted to the baseline-analytic sample. The
  default version starts March 2020; the `_monthly` variant additionally keeps Jan–Feb 2020
  for monthly-resolution plots/event studies (see the power caveat in [§2.1](#sec-2-1)).
- `person_history_future_long.rds` — a single **ready-to-plot stacked panel** per person:
  pre-baseline history → baseline row → COVID-study rows → main-survey follow-up. A
  `_mainonly` variant exists that drops the COVID-study rows, for comparisons using only
  the regular main-survey cadence.
- The four **analytic samples** built by `build_samples_2019()` (`code/lib/samples.R`), each
  nested inside the previous one:
  1. `s2019_all` — all baseline-analytic workers.
  2. `s2019_couples` — (1) restricted to people with a valid baseline partner link
     (`base_partner_rel` indicating spouse/cohabiting/civil partner).
  3. `s2019_covid` — (1) restricted to people also observed in the COVID study.
  4. `s2019_covid_couples` — (2) ∩ (3): baseline couples also observed in the COVID study.
  - `_plus_lmo` suffixed versions of all four (e.g. `s2019_all_plus_lmo.rds`) have the wide
    future-outcomes file merged in.

#### Couple-level datasets

- **Couple roster** (`baseline_couple_roster.rds`, `code/lib/samples.R:build_baseline_couple_roster()`)
  — one row per couple, built by self-joining baseline-analytic people to their baseline
  partner, keeping only **reciprocal** partner links where one partner is male and the
  other female (the heterosexual-couple restriction used throughout). A
  `..._both_in_covid.rds` variant keeps only couples where both spouses are observed in the
  COVID study.
- **Baseline couple-level dataset** (`s2019_baseline_couplelevel.rds`,
  `build_baseline_couple_dataset()`) — one row per couple, both partners' baseline variables
  side by side (`_h` / `_w` suffixes), plus couple-level **treatment and child-age
  variables** added by `add_couple_baseline_treatments()`: `treat_wife_key_notedu_husb_not_or_edu`,
  `treat_wife_key_notedu_any`, `treat_husb_shutdown_wife_not`, `sample_husb_notkey_or_edu`,
  and `child_age_group_2019` / `has_child_u10_2019` / `has_child_11_17_2019`. A
  `_both_in_covid` variant restricts to the COVID-observed roster. Pre-baseline couple
  history is merged in afterward.
- **COVID couple-wave panel** (`df_sample_long_covid_couplelevel.rds`,
  `build_covid_couple_long()`) — one row per **couple × COVID wave**, keeping only waves
  where *both* spouses are observed that wave, with couple treatment/child-group variables
  attached.
- **Future-outcomes couple panels** (`future_outcomes_couple_long_lmo.rds` /
  `_wide_lmo.rds`, `build_future_couple_long()` / `build_future_couple_wide()`) — the
  couple-level analogue of the person-level future-outcomes files, again in both `_long`
  (couple × wave) and `_wide` (one row per couple) shapes, each with `_both_in_covid` and
  `_monthly` variants.
- **Couple-level stacked panel** (`couple_history_future_long.rds`,
  `build_couple_history_future_long()`) — the couple-level analogue of
  `person_history_future_long.rds`: pre-baseline couple history → baseline couple row →
  COVID couple-wave rows → future couple-wave rows, one ready-to-plot long file. A
  `_mainonly` variant (and its `_both_in_covid` / `_monthly` combinations) drops the
  COVID-study rows.

#### Naming conventions

| Pattern | Meaning |
|---|---|
| `s2019_*` | A curated analytic **sample** (lives in `samples/`, not `derived/`) |
| `_couplelevel` / `_couple_*` | One row per **couple**, spouse variables suffixed `_h` / `_w` |
| `_long` | Panel shape: one row per person/couple **× time period** |
| `_wide` | One row per person/couple, outcomes spread across columns by period |
| `_both_in_covid` | Restricted to couples where **both** spouses are observed in the COVID study |
| `_plus_lmo` | The dataset with wide future outcomes (waves **L/M/N/O**) merged in |
| `_mainonly` | Excludes COVID-study rows; regular main-survey cadence only |
| `_monthly` | Keeps Jan–Feb 2020 for monthly-resolution use (see the power caveat in [§2.1](#sec-2-1)) |

If you need to trace exactly how a given `.rds` is built, `code/run/01_build_data.R` is
staged and commented step-by-step in this same order — read it alongside
`code/lib/samples.R`, `code/lib/family_baseline.R`, `code/lib/history.R`,
`code/lib/covid_panel.R`, and `code/lib/future_outcomes.R`.

---

<a id="sec-3"></a>

## 3. The codebase in one paragraph

An R pipeline turns raw Understanding Society (UKHLS) survey files into a pre-COVID
**baseline**, then person-level and couple-level **panels** spanning pre-COVID history, the
COVID waves, and later main-study waves. It assigns **baseline-SIC/SOC treatment groups**,
and emits **figures** (`figures/`) and **LaTeX table fragments** (`tables/`) that are
`\input{}` into Beamer slide decks and proposal documents. Raw data and most derived `.rds`
live **outside** the repo; the repo holds scripts, generated figures/tables, and TeX.

---

<a id="sec-4"></a>

## 4. Repository tour

```
code/
  run/      staged pipeline entrypoints (00_… → 99_…); run these
  lib/      reusable loaders, harmonizers, sample builders, plot/table/event-study helpers
  tests/    a few R test scripts
figures/    generated, shareable figures consumed by TeX (SL run nests under figures/SL/)
tables/     generated LaTeX table fragments + a few report artifacts (SL run → tables/SL/)
policies/   in-repo policy inputs: SOC/SIC lookups, ONS key-worker workbook,
            lockdown/restriction datasets, UK price index
grants/     proposal documents (Falk, Sapir) for broader framing
data_agreements/  UK Data Service licence paperwork (application, user agreements, forms)
*.tex       active slide decks, notes, draft manuscript scaffolding (repo root)
CLAUDE.md, AGENTS.md   agent guidance; ONBOARDING.md   this file
```

**"Which file do I open for problem X?"** (mirrors `AGENTS.md`):

| If the problem is about… | Start with… |
|---|---|
| paths, flags, where outputs live | `code/lib/config.R` |
| execution flow / what runs when | `code/run/00_master.R` |
| baseline construction / family structure | `code/lib/family_baseline.R` |
| COVID long panels | `code/lib/covid_loader.R`, `code/lib/covid_panel.R` |
| future outcomes / history panels | `code/lib/future_outcomes.R`, `code/lib/history.R` |
| treatment definitions / work-outside logic | `code/lib/work_groups.R` |
| key-worker classification | `code/lib/policies_keyworkers.R` |
| couple sample tables / composition figures | `code/lib/sample_tables.R`, `code/run/02c_sample_tables.R` |
| event-study outputs | `code/lib/event_study_regressions.R`, `code/run/03a_…R` |
| baseline-distribution figures for `couples_graphs_short.tex` | `code/lib/couple_baseline_dist_plots.R`, `code/run/02e_…R` |
| real (deflated) pay | `code/lib/real_pay.R` |

---

<a id="sec-5"></a>

## 5. Run scripts and flags in detail

`code/run/00_master.R` gives the execution order; this section goes one level deeper —
what each script actually does, what it reads/writes, when you'd edit it — and then
inventories every flag/constant worth knowing about, since these are the levers you can
pull without touching the underlying logic.

Note what these scripts *don't* contain: real function definitions. That split is
deliberate and enforced throughout the repo — see the "functions belong in `code/lib/`"
convention in [§10](#sec-10) — which is why every "Edit it when…" cell below usually points you at a
`code/lib/` file alongside (or instead of) the run script itself.

<a id="sec-5-1"></a>

### 5.1 Run scripts, one by one

| Script | What it does | Reads | Writes | Edit it when… |
|---|---|---|---|---|
| `00_check_inputs.R` | Pre-flight check: confirms required libs/run scripts, policy files, raw main/COVID wave files, and output folders all exist; prints a per-wave completeness report | raw wave files under `path_main`/`path_covid`; `policies/` | nothing (creates output folders if missing) | You add a new required policy file, a new wave range, or a new `code/lib/` file that later scripts depend on. |
| `00_master.R` | Orchestrates every stage below in its own fresh environment (`run_stage()`), so large objects from one stage don't leak into the next | — | — | You add a new stage script, want to skip stages during debugging (`RUN_*` flags, [§5.2](#sec-5-2)), or change the stage order. |
| `01_build_data.R` | Builds the baseline composite, pre-baseline history, COVID long panel, future outcomes, all couple-level files, and the four `s2019_*` analytic samples — the one script that produces almost everything else reads. Full walkthrough of what it builds is in [§2.4](#sec-2-4). | raw main/COVID wave files; `policies/` | everything under `derived/` and `samples/` ([§2.4](#sec-2-4)) | You add a new baseline variable, a new outcome that needs to exist in the couple-level files, or change a sample restriction (e.g. the baseline `jbstat` filter, the heterosexual-couple restriction). Almost every other run script depends on this one's outputs, so changes here ripple everywhere — treat it as the highest-leverage, highest-care file in `code/run/`. |
| `02_make_descriptives.R` | **Individual-level** (not couple-level — plain person rows, not the wife/husband-side-by-side couple files) COVID-sample descriptive figures: worked-at-all / work-status / furlough / WFH bar charts by industry-group (April/May 2020), plus over-time versions (housework, childcare, work-from-home, furlough, work-schedule-adapted-for-childcare) and keyworker-definition-vs-self-report comparison figures. Mainly a tool for **exploring and sanity-checking variables**, not for producing the couple-treatment research exhibits used in slides — those come from `02d`/`02e` instead. | `df_sample_long_covid.rds`, `df_sample_long_covid_couples.rds` | `figures/descriptives/covid/` | You want a new COVID-wave exploratory figure, or need to change the minimum-cell-size disclosure threshold (`MIN_N_DEFAULT`, [§5.2](#sec-5-2)). |
| `02b_make_future_descriptives.R` | **Individual-level**, same spirit as `02_make_descriptives.R` but for post-COVID main-survey follow-up outcomes: mean/share trends, categorical distributions, faceted-by-group versions, plus a small set of hand-picked figures. Also mainly for **exploring/sanity-checking** future-outcome variables, not final research exhibits — the couple-treatment versions in `02d` are what actually feed the slide decks. | `future_outcomes_long_lmo.rds`, `s2019_all.rds`, `s2019_couples.rds` | `figures/descriptives/future/` | You add a new future outcome to explore, or change which variables count as "headline" (the `HEADLINE_*`/`YM_*` outcome lists, [§5.2](#sec-5-2)). **Skipped entirely unless `MAKE_EXPLORATORY_EXTRA <- TRUE`.** |
| `02c_sample_tables.R` | Sample-composition LaTeX tables (wife×husband industry-group crosstabs at 3×3 and 5×5 resolution, youngest-child-age tables, treatment×child-age balance tables) and couple-composition figures (joint work-outside / WFH-some status over time), each produced for baseline / COVID / future / main-history-future-both-in-COVID samples, and repeated for the youngest-child-≤10 subsample | `s2019_baseline_couplelevel.rds`, `df_sample_long_covid_couplelevel.rds`, `future_outcomes_couple_long_lmo.rds`, `couple_history_future_mainonly_long_both_in_covid.rds` | `tables/sample_table_*.tex`, `figures/sample_composition/` | You add a new treatment variable to the balance tables (`BALANCE_TREATMENT_VARS`), or need a new sample cut beyond "all" / "youngest child ≤10". |
| `02d_make_couple_treatment_descriptives.R` | The main couple-treatment descriptive figures — **couple-level**, and the actual research exhibits (not exploratory): by-treatment-group trends over time for COVID outcomes, future outcomes, and main-survey history+future outcomes, in both "spouse-facet" and "child-age-grid" layouts, plus couple counts by treatment group | `df_sample_long_covid_couplelevel.rds`, `future_outcomes_couple_long_lmo.rds` (+ `_monthly`), `couple_history_future_mainonly_long*.rds` | `figures/couple_treatment/{covid_childgrids,future_childgrids,history_future_childgrids,spousefacets,counts}/` | You add a new outcome to `COVID_OUTCOMES`/`FUTURE_OUTCOMES`/`HISTORY_FUTURE_OUTCOMES` ([§5.2](#sec-5-2)), change the winsorization percentile, or adjust plot text sizes. This is the largest and most flag-driven run script — most `MAKE_*` config flags act on it. |
| `02e_make_couple_baseline_descriptives.R` | Baseline-distribution figures for `couples_graphs_short.tex`: one 2×2 (child-age × spouse) panel per outcome, pooling all COVID waves for COVID-measured outcomes and all main-survey waves for main-survey outcomes | `df_sample_long_covid_couplelevel.rds`, `couple_history_future_mainonly_long.rds` | `figures/couple_treatment/baseline_distributions/` | You add an outcome to `couples_graphs_short.tex` and need its baseline-distribution slide (add it to `COVID_OUTCOMES`/`MAIN_OUTCOMES` in this script). |
| `03a_make_couple_treatment_event_studies.R` | Runs the event-study regressions behind [§1.4](#sec-1-4)'s equation for every combination of treatment × spouse × child-age group × study (main/monthly-main/COVID) × controls × couple-FE, saves models, coefficients, and combined figures | `s2019_baseline_couplelevel*.rds`, `couple_history_future_mainonly*.rds`, `df_sample_long_covid_couplelevel.rds` | `figures/event_studies/<treatment_slug>/<fe_slug>/`, `derived/event_study_results/…` (models, coefficient `.rds`/`.csv`) | You add a new outcome to `MAIN_OUTCOMES`/`COVID_OUTCOMES`, change winsorization, or need a new sample variant. Uses `code/lib/event_study_regressions.R` for the actual regression logic — edit that file, not this one, if the specification itself needs to change. |
| `03_models_workoutside.R` | One-off OLS regression table (April 2020 `workoutside` on industry/occupation/education/age, by sex) via `modelsummary` | `df_sample_long_covid.rds` | `tables/workoutside_industry_comparison.tex` | You want to add/remove a model column or control variable in this specific table. Self-contained; nothing else depends on its output besides the TeX decks that `\input{}` it. |
| `04_lasso_workoutside.R` | Exploratory: cross-validated lasso logistic regression of `workoutside` (April 2020) on industry×occupation interactions, to data-mine which cells predict work-outside status best | `df_sample_long_covid.rds` | `tables/lasso_selected_terms.csv`, `lasso_industry_effects.csv`, `lasso_occupation_effects.csv`, `lasso_top_cells.csv` | You want to explore a different outcome or interaction set with the same data-driven approach ([§1.4](#sec-1-4) / `method.tex` "Data driven approach"). Exploratory only — not part of the main design. |
| `99_session_info.R` | Saves `sessionInfo()` for reproducibility | — | `tables/sessionInfo.txt` | Essentially never; it's a fixed reproducibility snapshot. |

**Ad hoc / diagnostic scripts** (in `code/run/` but not part of the numbered pipeline, and
not called from `00_master.R`):

- `diagnostics_any_work_hours_figures.R` — quality-check figures for `any_work`/hours
  consistency (missingness, zero-vs-positive hours, `any_work==1` but `hours<=0` and vice
  versa) across the person-level and couple-level COVID and future datasets. Run it whenever
  you're suspicious about how `any_work`/`hours`/`jbhrs` are behaving after a pipeline change.
- `diagnostics_telephone_survey_coverage.R` — the script behind the telephone-mode (`_t`)
  COVID file numbers quoted in [§2.3](#sec-2-3) (~3–5% more observations, two waves). Reads the raw
  `.dta` files directly (must be run where `path_covid` is real, i.e. never on an AI-coding
  machine) and reports, per wave, whether a `_t` file exists, which repo-used variables it
  contains, and how many additional `pidp`s it would add. Re-run this if you ever reconsider
  incorporating the telephone-mode files.

<a id="sec-5-2"></a>

### 5.2 Flags and levers you'll actually use

**Global switches — `code/lib/config.R`** (affect every script that sources it):

| Flag | Default | Effect |
|---|---|---|
| `DATA_LICENSE` | `"EUL"` | The master switch ([§7.3](#sec-7-3) in the data-licensing section below): `"EUL"` vs `"SL"` redirects input paths, output paths, and industry/occupation variable names everywhere. |
| `MAKE_EXPLORATORY_EXTRA` | `FALSE` | Gates the broader/noisier figure families: extra industry-level (not just group-level) plots and percent-vs-count variants in `02_make_descriptives.R`; the coarse `group_industry_based` grouping (vs. only the detailed one) in the same script; whether `02b_make_future_descriptives.R` runs **at all**; and the "both required / not required to have both spouses observed" extra count variant in `02d`. |
| `MAKE_FUTURE_ONLY_TREATMENT` | `FALSE` | Adds future-study-wave-only couple-composition figures (`02c`) and future-only treatment-group count figures (`02d`) alongside the main history+future versions. Off by default because the main-history-future versions already cover this ground more completely. |
| `MAKE_RESTRICTED_HUSB_NOTKEY_VARIANTS` | `FALSE` | Adds a second, restricted comparison sample (husband not a key worker, or education-only) for the wife-based treatments, in both `02d` (descriptive figures) and `03a` (event studies). A robustness variant, not the headline specification. |
| `MAKE_WIFE_KEY_ANY_TREATMENT` | `FALSE` | Adds `treat_wife_key_notedu_any` (wife key-worker non-education, *regardless* of husband) as a third treatment variable in `02d` and `03a`, alongside the two headline treatments. |
| `MAKE_COUPLE_TREATMENT_SPOUSEFACETS` | `FALSE` | Turns on the "spouse-facet" figure variants and standalone husits-distribution spousefacet figures in `02d` (the child-age-grid versions run regardless of this flag). |
| `MAKE_EVENT_STUDIES_COUPLE_FE` | `TRUE` | Whether `03a` also runs the couple-fixed-effects version of every event study (in addition to no-FE). Couple FE absorbs the treatment main effect and any time-invariant baseline controls ([§1.4](#sec-1-4)). |
| `MAKE_EVENT_STUDIES_BASELINE_CONTROLS` | `TRUE` | Whether `03a`'s no-FE event studies also run a baseline-controls version (in addition to no-controls). Only applies to the no-FE arm — baseline controls are collinear with couple FE. |

Also in `config.R`: the wave-window constants that define the panel's scope —
`covid_waves`, `future_waves`, `history_waves` ([§2.1](#sec-2-1)), and the pay-deflation anchor
`REAL_PAY_BASE_YM` (currently December 2019, used by `code/lib/real_pay.R`).

**Stage toggles — `code/run/00_master.R`:**

- `RUN_CHECK_INPUTS`, `RUN_BUILD_DATA`, `RUN_DESCRIPTIVES`, `RUN_FUTURE_DESCRIPTIVES` (defaults
  to `MAKE_EXPLORATORY_EXTRA`), `RUN_SAMPLE_TABLES`, `RUN_COUPLE_TREATMENT_DESCRIPTIVES`,
  `RUN_COUPLE_BASELINE_DESCRIPTIVES`, `RUN_EVENT_STUDIES`, `RUN_MODELS`, `RUN_LASSO`,
  `RUN_SESSION_INFO` — flip any of these to `FALSE` to skip that stage on a given run (e.g.
  while iterating on just one stage's output).
- `STOP_AFTER_EACH` (`FALSE`) — set `TRUE` to halt the whole run after each stage, useful for
  stepping through the pipeline while debugging.

**Per-script constants worth knowing** (not centralized in `config.R`, but the first thing
to change if you need different behavior from a specific script):

| Constant | Where | Default | What it controls |
|---|---|---|---|
| `MIN_N_DEFAULT` | `02_make_descriptives.R` | `25` | Minimum cell size before a bar is shown — a disclosure/noise control. |
| `RUN_AUTO_ALL` | `02b_make_future_descriptives.R` | `FALSE` | Whether to also auto-generate an unfiltered "plot every future outcome" pass on top of the curated figures. |
| `HEADLINE_NUMERIC_OUTCOMES`, `HEADLINE_CATEGORICAL_OUTCOMES`, `YM_NUMERIC_OUTCOMES`, `YM_CATEGORICAL_OUTCOMES` | `02b_make_future_descriptives.R` | — | The actual lists of which future outcomes get plotted. Add a variable here to get it plotted automatically. |
| `WINSORIZE_PCT` | `02d`, `03a` | `0.99` | Upper-tail winsorization percentile applied to continuous outcomes before plotting/estimating. |
| `COVID_OUTCOMES`, `FUTURE_OUTCOMES`, `HISTORY_FUTURE_OUTCOMES`, `MAIN_OUTCOMES` | `02d`, `03a`, `02e` | — | The outcome lists actually plotted/estimated in each script — the most common thing you'll want to extend when adding a new outcome to the descriptives or event studies. |
| `AXIS_TEXT_SIZE`, `AXIS_TITLE_SIZE`, `STRIP_TEXT_SIZE`, `LEGEND_TEXT_SIZE`, `LEGEND_TITLE_SIZE`, `TITLE_SIZE` | `02d`, `02e` | 13–16 | Plot text sizing, tuned for slide legibility. |
| `min_n`, `tol` | `04_lasso_workoutside.R` | `20`, `0.02` | Factor-lumping threshold for rare industry/occupation categories, and the lambda tolerance rule (how far above the CV-optimal deviance to relax the lasso penalty). |

---

<a id="sec-6"></a>

## 6. UKHLS variables we use and how we process them

This section is the variable-level companion to [§2](#sec-2): not what the data collections are, but
exactly which UKHLS variables this repo pulls, how baseline is actually selected at the code
level, and how raw survey codes turn into the harmonized/derived variables the rest of the
pipeline uses. Everything below is grounded directly in `code/lib/family_baseline.R`,
`code/lib/future_outcomes.R`, `code/lib/history.R`, `code/lib/covid_loader.R`,
`code/lib/covid_panel.R`, `code/lib/harmonize_outcomes.R`, `code/lib/husits_harmonization.R`,
`code/lib/work_groups.R`, `code/lib/policies_keyworkers.R`, and `code/lib/real_pay.R`.

**This section summarizes; it doesn't replace reading the code.** Every one of those files
has detailed header comments spelling out each raw variable's meaning, its coded values
(e.g. `1 employed, 2 self-employed, …`), and exactly how it's cleaned or recoded — that's
where this section's content actually came from. If you need a level of detail beyond what's
here (an edge case, an exact value mapping, a variable this guide doesn't mention), open the
relevant file first; it's usually faster than guessing from the UKDS documentation.

<a id="sec-6-1"></a>

### 6.1 Useful UKHLS/UKDS documentation links

- **Survey timeline** — https://www.understandingsociety.ac.uk/documentation/mainstage/survey-timeline/
  — calendar of main-study wave fieldwork periods; useful alongside [§2.1](#sec-2-1)'s wave↔year mapping.
- **Main survey variable search** — https://www.understandingsociety.ac.uk/documentation/mainstage/variables/
  — look up any main-study variable (e.g. `jbstat`, `husits`) by name across waves.
- **COVID variable search** — https://www.understandingsociety.ac.uk/documentation/covid-19/variables/
  — the same, for the COVID-19 Study variables in [§6.6](#sec-6-6).
- **Main survey (EUL) documentation, incl. questionnaires** — https://datacatalogue.ukdataservice.ac.uk/studies/study/6614#details
- **LAD data (SL) documentation** — https://datacatalogue.ukdataservice.ac.uk/studies/study/6666#details
- **Main survey (SL) documentation** — https://datacatalogue.ukdataservice.ac.uk/studies/study/6931#documentation
- **Geography data user guide** — https://doc.ukdataservice.ac.uk/doc/6931/mrdoc/pdf/main_survey_user_guide_geography.pdf
- **COVID survey documentation, incl. questionnaires** — https://datacatalogue.ukdataservice.ac.uk/studies/study/8644#details

<a id="sec-6-2"></a>

### 6.2 Variable naming: prefixes and suffixes, in one place

The pieces above each introduce one of these as they come up; this is the full list
together, so you don't have to hunt back through [§6.3](#sec-6-3)–[§6.9](#sec-6-9) to remember what a name means.

**Prefixes**

| Prefix | Meaning | Added by |
|---|---|---|
| `base_` | A **baseline** value — this person's I/J/K 2019 row ([§6.3](#sec-6-3)). Applied to every column except `pidp` | `build_baseline()`, `family_baseline.R` |
| `hist_` (person) / `hist_couple_` (couple) | A **pre-baseline history** summary statistic (e.g. `hist_mean_jbhrs`, `hist_n_obs`) — one row per person/couple, summarizing all their pre-baseline waves | `summarise_prebaseline_history()` / `summarise_prebaseline_couple_history()`, `history.R` |

**Suffixes added by this pipeline**

| Suffix | Meaning | Added by |
|---|---|---|
| `_h` / `_w` | **Husband** / **wife** — every couple-level file has both spouses' variables side by side with these suffixes (e.g. `jbhrs_h`, `husits_w`) | The various `build_*_couple_*()` functions in `samples.R`/`history.R` ([§2.4](#sec-2-4)) |
| `_real` | Inflation-adjusted to constant **December 2019 pounds** ([§6.9](#sec-6-9)) | `add_real_pay_vars()`, `real_pay.R` |
| `_code` | A numeric 1–4 harmonized code (e.g. `wfh_code`) | `combine_wfh()`, `harmonize_outcomes.R` |
| `_cat` | The **labelled factor** version of a `_code`-style variable (e.g. `wfh_cat`, `husits_cat`) | `combine_wfh()` (`harmonize_outcomes.R`); `label_husits()` (`husits_harmonization.R`) |
| `_raw` | The value **before** harmonization/recoding (e.g. `husits_raw`) — kept alongside the cleaned version rather than discarded | `add_husits_main_vars()` / `add_husits_covid_vars()`, `husits_harmonization.R` |

**Suffixes that come from UKHLS itself** (not created by this pipeline, but worth knowing
since they're everywhere in the raw variable names):

| Suffix | Meaning |
|---|---|
| `_dv` | UKHLS "derived variable" — pre-computed by UKHLS itself from raw questionnaire items (e.g. `age_dv`, `isced11_dv`, `jbft_dv`) |
| `_cc` | UKHLS "condensed code" — the coarser EUL-edition industry/occupation codes (`jbsic07_cc`, `jbsoc10_cc`), as opposed to the detailed SL-only `jbsic07`/`jbsoc10` ([§6.4](#sec-6-4), [§7.3](#sec-7-3)) |
| `_cv` | The COVID-study's own name for a main-survey concept (e.g. `howlng_cv`, `husits_cv`) — this pipeline renames these away immediately on load ([§6.5](#sec-6-5)), so you'll only see `_cv` in the raw `.dta` files, never in derived data |

---

<a id="sec-6-3"></a>

### 6.3 How the pre-pandemic baseline is actually selected

`build_baseline()` — defined in `code/lib/family_baseline.R`, called from
`code/run/01_build_data.R` (Step 1) — builds the composite baseline from waves I, J, K.

The selection rule itself is described in [§2.2](#sec-2-2) (latest of K/J/I falling in 2019); here's
how that's actually implemented:

1. **Wave K** rows in 2019 are used first.
2. **Wave J** rows in 2019 fill in anyone not already covered by wave K.
3. **Wave I** rows in 2019 fill in anyone still missing.

(In code, K and J are filtered with `intdaty_dv < 2020` and I with `intdaty_dv == 2019` —
equivalent in practice, since neither K nor J fields any interviews before 2019.)

Other things `build_baseline()` does while assembling the composite:

- Renames every column with a `base_` prefix ([§6.2](#sec-6-2)).
- **Recodes education.** UKHLS's derived education variable is `isced11_dv`, coded on the
  international ISCED 2011 scale (roughly: no qualification → school-leaving → vocational →
  degree → higher degree). Code 8 on that scale is a doctorate/PhD; `build_baseline()` merges
  it into code 7 (Master's degree) so there's one combined "higher degree" category instead
  of splitting off a small PhD group, and UKHLS's negative missing-data codes become `NA`.
- **Computes `base_health_sf`.** UKHLS asks general self-rated health via two
  *mutually-exclusive routed* questions — `sf1` and `scsf1` — where only one is ever put to a
  given respondent (which one depends on survey routing, not choice). `build_baseline()`
  applies `combine_health()` ([§6.6](#sec-6-6)): take `scsf1` if present, else `sf1`, so every baseline row
  ends up with one health variable regardless of which question that person happened to get.
- **Deflates the baseline's monetary variables to real terms immediately** — `basrate`
  (hourly pay), `paygu_dv` (usual gross pay), `fimnlabgrs_dv` (gross labour income),
  `fimngrs_dv` (gross personal income), and `fihhmngrs_dv` (gross household income) — rather
  than waiting for a later stage (the same CPIH deflation described in [§6.9](#sec-6-9)).
- **Baseline industry/occupation treatment grouping** — `group_industry_based` /
  `group_industry_based_detailed`, the key-worker/shutdown-sector classification described in
  [§6.8](#sec-6-8) — is added right after `build_baseline()` returns, as a separate step in
  `01_build_data.R`, not inside `build_baseline()` itself.

**Family/partner/children construction** — `build_family_data()`, also in
`family_baseline.R`, called internally by `clean_baseline_wave()` (baseline) and by
`load_main_wave_with_family()` in `future_outcomes.R` (history and future waves) — comes
from two other main-survey files per wave, not `indresp`:

- `{wave}_egoalt.dta` — the relationship-grid file. `relationship_dv %in% c(1,2,3)`
  (husband/wife, partner/cohabitee, civil partner) identifies a person's **partner**
  (`partner_pidp`, `partner_rel`); `relationship_dv %in% 9:12` identifies **children**
  in the household.
- `{wave}_indall.dta` — used only to look up each identified child's `age_dv`, since egoalt
  itself doesn't carry age.

From these, `build_family_data()` derives `n_children`, `n_children_18_under`,
`n_children_16_under`, `n_children_10_under`, `age_youngest_child`, and a `family_id` built
from the sorted pair of partner `pidp`s (so both partners resolve to the same id). Children
with a negative `age_dv` (a UKHLS missing-data code, [§6.10](#sec-6-10)) are dropped from these counts
entirely — treated as not a valid child record, not as "child present, age unknown."

<a id="sec-6-4"></a>

### 6.4 Variables pulled from every main-survey wave (baseline, history, and future alike)

Baseline, pre-baseline history, and future follow-up waves all funnel through the **same
underlying variable list**, via three loader functions that all pull nearly identical
columns from `{wave}_indresp.dta`:

- `clean_baseline_wave()` — defined `family_baseline.R`, called internally by
  `build_baseline()` — for baseline (I/J/K).
- `load_history_wave()` (`history.R`) → `load_main_wave_with_family()` (`future_outcomes.R`)
  — `load_history_wave()` is called by `build_prebaseline_history_long()`, itself called
  from `code/run/01_build_data.R` (Step 1b) — for pre-baseline history.
- `load_main_wave_with_family()` directly, called by `build_future_outcomes_long()`
  (`future_outcomes.R`), itself called from `code/run/01_build_data.R` (Step 5) — for future
  follow-up waves.

This is why the same outcome (e.g. `jbhrs`) means the same thing whether you're looking at
history, baseline, or future rows.

| Variable | Meaning |
|---|---|
| `pidp`, `hidp` | Person id (stable across waves/studies); household id (wave-specific) |
| `sex`, `age_dv`, `gor_dv`, `isced11_dv` | Sex; derived age; region; derived education |
| `jbstat` | Labour-market status (1 employed, 2 self-employed, …) |
| `jbhas` | Did paid work last week (1 yes, 2 no) |
| `jboff` | Away from a job last week without working (1 yes, 2 no) — distinguishes "has a job but didn't work" from "no job" |
| `jbsic07_cc`, `jbsoc10_cc` | Condensed industry (SIC 2007) / occupation (SOC 2010) — always present |
| `jbsic07`, `jbsoc10` | Detailed 4-digit SIC/SOC — **baseline only**, and only under the SL edition (silently absent under EUL via `any_of()`); history/future loads never request these at all |
| `jbft_dv`, `jbhrs`, `jbot`, `jbsect`, `jbterm1`, `basrate` | Full/part-time; usual weekly hours; overtime hours; public/private sector; permanent/temporary; basic hourly pay rate |
| `fimngrs_dv`, `fihhmngrs_dv` | Gross personal income/month; gross household income (month before interview) |
| `paygu_dv` | Usual gross pay per month from the **main job only** |
| `fimnlabgrs_dv` | Total gross monthly labour income — `paygu_dv` (main job) + `seearngrs_dv` (self-employment) + `j2pay_dv` (second job). Broader than `paygu_dv`, not a renamed copy of it |
| `jbpl`, `jbwah` | Work location (1 home/2 employer/3 travelling/4 other); WFH frequency (only asked if `jbpl != 1`) — harmonized together in [§6.7](#sec-6-7) |
| `mastat_dv`, `sppid`, `nchild_dv`, `ndepchl_dv` | Marital status; spouse's pidp; number of children; number of dependent children |
| `howlng`, `husits`, `chcare`, `aidadhrs` | Housework hours; childcare-responsibility ([§6.7](#sec-6-7)); childcare (often binary); caring hours/week |
| `scghq2_dv`, `scghq1_dv`, `sclfsato` | Two scorings of the **GHQ-12** (General Health Questionnaire, a standard 12-item psychological-distress/wellbeing screen): `scghq2_dv` is **caseness** — each item scored 0/0/1/1, summed 0–12, a simple count of symptoms above threshold, commonly used to flag likely distress; `scghq1_dv` is the **Likert score** — each item scored 0/1/2/3, summed 0–36, a finer-grained severity measure. `sclfsato` is overall life satisfaction (1–7) |
| `sf1`, `scsf1` | Self-reported general health — routed, only one exists per respondent ([§6.7](#sec-6-7)) |
| `intdatm_dv`, `intdaty_dv` | Interview month/year (negative = missing; imputed as the median month within the same interview-year when only the month is missing) |

Baseline additionally carries `jbsic07`/`jbsoc10` (SL only, see above) since those are what
the treatment classification in [§6.9](#sec-6-9) needs.

<a id="sec-6-5"></a>

### 6.5 Variables pulled from the COVID study

`code/lib/covid_loader.R`'s `load_covid_wave()` reads `{wave}_indresp_w.dta` (web-mode only —
[§2.3](#sec-2-3)) and keeps the columns below; `merge_covid_waves_wide()` (same file) merges all waves
side by side. Both are called from `code/run/01_build_data.R` (Step 2).

| Variable | Meaning |
|---|---|
| `furlough`, `ff_furlough` → renamed `fffurlough` | Furlough status; an alternate furlough measure |
| `hours` | Hours worked last week |
| `blwork`, `blhours`, `blwah` | Baseline (Jan–Feb 2020) work status / weekly hours / WFH frequency, asked retrospectively |
| `sempderived` | 1 employed, 2 self-employed, 3 both, 4 not employed |
| `wah` | WFH frequency: 1 always, 2 often, 3 sometimes, 4 never |
| `howlng_cv` → renamed `howlng` | Housework hours (COVID-study name for the main-survey `howlng` concept) |
| `keyworker`, `keyworksector` | Self-reported key-worker status; self-reported key-worker sector (1–8 key, 9 not) |
| `timechcare` | Childcare/home-schooling hours (continuous) — **COVID-only, no main-survey equivalent** |
| `husits_cv` → renamed `husits` | Childcare-responsibility report, COVID coding ([§6.7](#sec-6-7)) |
| `workchsch`, `workchsch2` | Whether work schedule changed because of home-schooling/childcare |

The loader renames `howlng_cv`→`howlng` and `husits_cv`→`husits` immediately on load so every
downstream script can refer to one name regardless of which study a row came from — but the
*coding scheme* underneath `husits` still differs by study until `husits_harmonization.R`
runs ([§6.7](#sec-6-7)).

<a id="sec-6-6"></a>

### 6.6 Harmonizing variables that differ between main and COVID

- **Work location / WFH** — `combine_wfh()`, defined `code/lib/harmonize_outcomes.R`, called
  from `code/run/01_build_data.R` (Step 5, future) and `history.R`'s
  `add_history_derived_variables()` (COVID rows don't need it — see below): the main survey
  splits this across two branching variables, `jbpl` (work location) and `jbwah` (WFH
  frequency, only asked if `jbpl != 1`). `combine_wfh()` merges them into one `wfh_code`
  (1 Always…4 Never) / `wfh_cat` pair: if `jbpl == 1` (at home), `wfh_code` is forced to 1
  (Always); otherwise it's just `jbwah`. The COVID study's `wah` is already on this same
  1–4 scale, so it needs no branching logic, just the rename above.
- **Housework hours**: COVID's `howlng_cv` is renamed to `howlng` at load time — same
  concept, slightly different recall window (COVID asks about last week; main asks about a
  usual week).
- **General health** — `combine_health()`, defined `harmonize_outcomes.R`, called from
  `family_baseline.R`'s `build_baseline()` (as `base_health_sf`), `history.R`'s
  `add_history_derived_variables()`, and `code/run/01_build_data.R` (Step 5, future):
  `sf1`/`scsf1` are mutually exclusive due to UKHLS routing (only one is ever asked per
  respondent) — `health_sf <- scsf1`, falling back to `sf1` where `scsf1` is missing.
  Recoded to an ordered factor (Excellent…Poor) — one function, applied identically
  everywhere.
- **Childcare responsibility (`husits`)** (`code/lib/husits_harmonization.R`) — asked of
  **each spouse separately**: "who is mainly responsible for looking after the children?"
  Answers are **ego-centric** — "self" means whoever is answering, not a fixed person — so
  the same underlying reality (say, the wife does most of the childcare) shows up as "mainly
  self" in the wife's answer and "mainly partner" in the husband's. The **final harmonized
  variable** (what `husits` means after processing, regardless of which study or spouse it
  came from) is a 4-category factor: **1 Mainly self, 2 Mainly partner, 3 Shared, 4 Someone
  else/other** — produced by `label_husits()`. Getting there requires reconciling two very
  different raw response scales:
  - Main-stage raw coding is already 1–4 with exactly those meanings, so no remapping is
    needed beyond cleaning negative/missing codes (`clean_husits_main()`).
  - COVID raw coding uses a finer 1–9 scale that must be collapsed onto the same 1–4 meaning
    (`clean_husits_covid()`): 1/2 → "mainly me" (always/usually) → **1**; 4/5 → "mainly
    partner" (usually/always) → **2**; 3 → shared → **3**; 6/7/9 → other/someone else → **4**;
    8 (not applicable) → treated as **missing**, not folded into "other."
  - `clean_husits_main()` / `clean_husits_covid()` produce the harmonized 1–4 code;
    `label_husits()` (same file) attaches the four labels above — all three defined
    in `husits_harmonization.R`, called from `code/lib/covid_panel.R`'s
    `build_covid_long_panel()` and from the `add_husits_main_vars()`/`add_husits_covid_vars()`
    wrappers (same file), which are in turn called from `family_baseline.R`'s
    `clean_baseline_wave()` and `future_outcomes.R`'s `load_main_wave_indresp()`.
  - Couple-level directional variables are then built from **both spouses' reports** by
    `add_couple_husits_direction_vars()` (also `husits_harmonization.R`, called from
    `code/run/01_build_data.R` via the local `add_baseline_couple_husits_direction()` wrapper,
    and from `history.R`'s `build_prebaseline_couple_history_long()`): e.g.
    `husits_wife_main_wreport` (wife says she's mainly responsible) vs.
    `husits_wife_main_hreport` (husband says the wife is mainly responsible) — plus averages
    across whichever report(s) are available. The
    `husits_wife_main_both` outcome used in the slide decks ([§1.4](#sec-1-4)'s design, [§11](#sec-11)'s TeX table)
    requires **both** spouses to agree the wife is mainly responsible before it equals 1.

<a id="sec-6-7"></a>

### 6.7 Derived outcome indicators — how "did they work" is actually built

These are the workhorse binary/categorical outcomes behind most figures and event studies —
`make_any_work_covid()`/`make_any_work_future()`, `make_work_last_week_status_main()`/
`_covid()`, `make_workoutside_covid()`/`_future()`, and `make_wfh_some_covid()`/`_future()`,
all defined in `code/lib/work_groups.R`. The COVID versions are called from
`code/lib/covid_panel.R`'s `build_covid_long_panel()` (itself called from
`code/run/01_build_data.R`, Step 3); the main/future versions are called from `history.R`'s
`add_history_derived_variables()` and from `code/run/01_build_data.R` (Step 5, future). Each
has a COVID version and a main-survey/"future" version, built from different raw variables
but designed to mean the same thing. In every cell below, the input variables (`sempderived`,
`hours`, `jbhas`, `jboff`, etc.) have already had UKHLS's negative missing-data codes
converted to `NA` ([§6.10](#sec-6-10)) before this logic runs:

| Outcome | COVID logic (`sempderived`, `hours`, `wah`) | Main/future logic (`jbstat`/`jbhas`, `jbhrs`, `wfh_code`) |
|---|---|---|
| `any_work` | `sempderived==4` (not employed) → 0; else 1 if `hours>0`, 0 if `hours==0` | `jbhas==1` → 1, `jbhas==2` → 0 (direct "did you work last week" question — future/history rows do **not** use `jbhrs` for this) |
| `work_last_week_status` (1 worked / 2 has job didn't work / 3 no job) | 1 if `hours>0`; 2 if employed with `hours==0`; 3 if `sempderived==4` (not employed) | 1 if `jbhas==1`; 2 if `jbhas==2 & jboff==1` (has a job, didn't work); 3 if `jbhas==2 & jboff==2` (no job) |
| `workoutside` | 0 if `hours<=0`; else 0 if `wah==1` (always WFH), 1 if `wah` 2–4 | 0 if `jbstat` not in {1 employed, 2 self-employed} or `jbhrs<=0`; 0 if `wfh_code==1` (always WFH); 1 if `wfh_code` 2–4 |
| `wfh_some` | 0 if `hours<=0`; 1 if `wah` 1–3 (any WFH); 0 if `wah==4` (never) | 0 if `jbstat` not in {1, 2} (not employed) or `jbhrs<=0`; 1 if `wfh_code` 1–3; 0 if `wfh_code==4` |

Two subtleties worth knowing:

- **The COVID long panel (`df_sample_long_covid.rds`, [§2.4](#sec-2-4)) isn't just the nine real COVID
  waves `ca`–`ci`.** It also contains two extra, **synthetic** rows per person — "synthetic"
  meaning they're not an actual COVID-study interview, just pre-pandemic information
  re-packaged to look like one more row in the same `wave` column, so the COVID event studies
  in [§1.4](#sec-1-4) have a usable pre-period to compare against without waiting on a real main-survey
  follow-up. Both are added inside `build_covid_long_panel()` (`code/lib/covid_panel.R`,
  called from `code/run/01_build_data.R`'s Step 3), and both take literal values in the
  `wave` column alongside `"ca"`…`"ci"`:
  - **`wave == "2019"`** — built from the person's **main-survey baseline** ([§6.3](#sec-6-3)):
    `base_jbstat` → `sempderived`, `base_jbhrs` → `hours`, `base_howlng` → `howlng`, with
    `wah` forced to missing since pre-2020 main-survey waves never asked the COVID-style WFH
    question. This is the same 2019 baseline used everywhere else in the pipeline, just
    relabelled to sit in the COVID panel's time axis.
  - **`wave == "baseline"`** — a *second, independent* pre-period row, built instead from the
    COVID study's **own** retrospective questions about **Jan–Feb 2020** specifically
    (`blwork`/`blhours`/`blwah` — "before lockdown work/hours/WFH"):
    - Unlike the `"2019"` row, these questions were **not asked just once** — UKHLS repeated
      this Jan–Feb-2020 recall question in several early COVID waves (not every wave, and not
      everyone answers every wave they're asked). So for each person,
      `build_covid_long_panel()` has to pick **one** answer out of potentially several: it
      takes each person's **earliest valid answer in wave order** (`ca` first, then `cb`,
      `cc`, … — via `first_valid()` in `utils.R`, which also treats UKHLS's `-8` "not
      applicable" code as invalid, same as a genuine missing value), and uses that single
      value for the `"baseline"` row regardless of which wave it came from.
    - Earliest-valid is used on the assumption that a recollection given closer to the actual
      Jan–Feb 2020 period (i.e. in the `ca` wave, fielded in April 2020) is less subject to
      recall drift than the same question answered again a wave or two later.
    - This row has no housework/childcare measure and leaves those missing.
  - Two rows exist, not one, for two reasons:
    - **They answer slightly different questions.** `"2019"` gives the standard annual
      baseline (same source/timing as every other baseline variable in this repo);
      `"baseline"` gives a second data point measured closer to the actual onset of
      restrictions, from a question asked as part of the COVID survey rather than recalled a
      year-plus later.
    - **They cover different outcomes.** Some concepts — most notably **working from home**
      — simply weren't asked about at all in the pre-2020 main survey, so the `"2019"` row
      has no way to give a WFH baseline (`wah` is forced to missing there, as noted above).
      The COVID study's Jan–Feb-2020 retrospective questions (`blwah`, in this case) exist
      *precisely because* UKHLS added them to let researchers construct a pre-pandemic
      baseline for outcomes the regular survey never measured — so the `"baseline"` row is
      the *only* one of the two that can supply a baseline `workoutside`/`wfh_some` value at
      all. Event studies and descriptive figures pick whichever row fits the outcome and
      comparison being made ([§6](#sec-6)'s event-study reference-period notes, [§1.4](#sec-1-4)).
- **`workoutside`/`wfh_some` are wave-gated, not just row-gated.** If the WFH question
  wasn't asked at all in a given wave (`wfh_question_available`), *every* row in that wave —
  including non-workers — gets `NA`, rather than a potentially-misleading 0. This is exactly
  why the two synthetic rows above have these set to missing rather than 0: neither
  pre-pandemic data source asked the COVID-style WFH question.

<a id="sec-6-8"></a>

### 6.8 Pre-pandemic treatment/exposure classification (SIC/SOC → key worker / shutdown sector)

This is the mechanics behind `group_industry_based` / `group_industry_based_detailed`,
computed by `add_baseline_work_groups()` / `add_baseline_work_groups_sl()` (both defined
`code/lib/work_groups.R`, called from `code/run/01_build_data.R` for the baseline itself
(Step 1) and again for the future panel (Step 5), and from `code/lib/covid_panel.R`'s
`build_covid_long_panel()` for the COVID panel) — the exposure classification introduced in
[§1.4](#sec-1-4), computed once from **baseline** SIC/SOC and carried through to every downstream file by
joining on `pidp`/`couple_id`, never recomputed from a person's current job. The baseline SIC
and SOC codes are cleaned of negative UKHLS codes to `NA` first (`base_sic_clean`/
`base_soc_clean`, [§6.10](#sec-6-10)) — so a job with an invalid/missing code is never accidentally
matched into a treatment group.

- **Shutdown sector**: from the IFS BN278 endnote (Joyce & Xu 2020).
  - **EUL**: condensed 2-digit SIC codes `{55, 56, 79, 90, 91, 92, 93, 96}`.
  - **SL**: the exact 4-digit SIC "CLASS" list, tested by `is_ifs_shutdown_sic()` (defined
    `work_groups.R`, called internally by `add_baseline_work_groups_sl()`) — e.g.
    accommodation/food service (4-digit range 5510–5630), travel agencies (7911–7990),
    childcare (8510, 8891), arts/leisure except artistic creation (9001–9329 excl. 9003),
    personal care except funerals (9601–9609 excl. 9603), domestic services (9700). This is
    finer than the EUL 2-digit list — exactly the resolution gain the Special Licence
    application (§1's design section) argues for.
- **Key worker**: from the ONS SOC×SIC key-worker reference table
  (`policies/keyworkersreferencetableupdated2.xlsx`, sheet 4), read and crosswalked by
  `code/lib/policies_keyworkers.R`.
  - **EUL**: `build_keyworker_crosswalk()` (defined `policies_keyworkers.R`, called from
    `code/run/01_build_data.R`'s Step 0) collapses the detailed sheet to condensed
    (SOC÷10, SIC÷100) cells, each flagged key if *any* underlying detailed cell in it is key.
    Sub-typed by hand-coded SIC/SOC rules in `add_baseline_work_groups()` (`work_groups.R`)
    into three EUL categories: health & social services, education, and public safety &
    essential government — each mutually exclusive, using cross-checks between SIC and SOC
    to resolve ambiguous cases (e.g. SOC 118 is only "health & social" if paired with SIC
    86–88). Similar SIC/SOC cross-check rules resolve ambiguous cases for the other two
    categories too; see `work_groups.R` for the full rule set.
  - **SL**: `build_keyworker_crosswalk_detailed()` (defined `policies_keyworkers.R`, called
    from `code/run/01_build_data.R`'s Step 0, SL only) keeps the full (SOC 4-digit × SIC
    4-digit) resolution — a job is key only if that *exact* combination is flagged, collapsed
    to one of eight ONS groups (health & social care, education & childcare, food &
    necessary goods, transport, utilities & communication, and three government/public-safety
    groups merged into one "public services and government" label). Requires **both**
    detailed codes to be observed; ties across ONS groups are broken by a fixed priority
    order (`KEYWORKER_GROUP_PRIORITY`).
  - Either way, `group_industry_based` is the collapsed key-worker/shutdown/other/missing
    factor used for headline treatment; `group_industry_based_detailed` keeps the key-worker
    sub-type (used for the detailed-groups figures and the education exclusion in the
    treatment definitions, [§1.4](#sec-1-4)).

<a id="sec-6-9"></a>

### 6.9 Real (inflation-adjusted) pay

`add_real_pay_vars()` — defined `code/lib/real_pay.R`, called from `family_baseline.R`'s
`build_baseline()` (baseline) and `future_outcomes.R`'s `load_main_wave_indresp()`
(history/future) — converts nominal monetary variables to constant **December 2019 pounds**
using the ONS CPIH all-items monthly index (`policies/uk_price_index_monthly.csv`, series
`L522`; base month set by `REAL_PAY_BASE_YM` in `config.R`, loaded internally via
`load_real_pay_deflator()`, same file). Deflated variables: `basrate`, `paygu_dv`,
`fimnlabgrs_dv`, `fimngrs_dv`, `fihhmngrs_dv` — each gets a `_real` counterpart (e.g.
`paygu_dv_real`), computed as `nominal × (CPIH_{2019m12} / CPIH_t)` where `t` is the
respondent's interview month. Negative/invalid raw values are set to missing before
deflating; a missing interview month means a missing `_real` value for that row
(logged as a warning, not silently dropped).

<a id="sec-6-10"></a>

### 6.10 Missing values: UKHLS codes, pipeline-created gaps, and when missingness is meaningful

**The general UKHLS convention.** Negative numeric codes are how UKHLS marks "don't know,"
"refused," "not applicable," and similar non-answers — not real values on the variable's
scale. This pipeline applies **the same rule everywhere a UKHLS numeric variable is used as
a number**: any negative code becomes `NA` before it's used in a comparison, recode, or
`case_when()`. This is one repeated convention, not a series of one-off decisions — it's
applied (among other places) to `isced11_dv` ([§6.3](#sec-6-3)), the children's `age_dv` ([§6.3](#sec-6-3)), the
monetary variables deflated in [§6.9](#sec-6-9), `husits` ([§6.6](#sec-6-6)), the baseline SIC/SOC codes feeding the
treatment classification ([§6.8](#sec-6-8)), and the raw employment-status/hours variables
(`sempderived`, `hours`, `jbhas`, `jboff`) behind every outcome in [§6.7](#sec-6-7)'s table.
`first_valid()` (`utils.R`, used in [§6.7](#sec-6-7)'s `"baseline"`-row construction) additionally
treats UKHLS's `-8` ("Not In Universe") code as invalid on the same footing as a genuine
missing value.

**Missingness the pipeline itself introduces** — i.e. not present as missing in the raw
survey, but created while building a derived variable or panel row: the synthetic COVID-panel
rows are the main example ([§6.7](#sec-6-7)) — `wah` is forced missing in the `"2019"` row, and
housework/childcare are forced missing in the `"baseline"` row, because those concepts
simply weren't measured in that context. The wave-level `wfh_question_available` gate (also
[§6.7](#sec-6-7)) is the same idea applied to a whole wave at once rather than one row.

**When missingness is used as information, not just "no data":**

- **Husits code 8** ("not applicable") is deliberately kept as `NA` rather than folded into
  the "other" category ([§6.6](#sec-6-6)) — preserving "this respondent had no childcare situation to
  report" as distinct from "this respondent gave an other/unusual answer."
- **The WFH wave-gate** ([§6.7](#sec-6-7)) makes `NA` mean specifically "this wave never asked the
  question," a different real-world state from "this person doesn't work from home" (`0`) —
  collapsing the two would misrepresent wave-to-wave comparisons.
- **Non-workers end up coded as `0` hours/WFH downstream, even though UKHLS's own raw value
  for them is `-8`, not `0`.** UKHLS doesn't ask non-employed people how many hours they
  worked or whether they WFH, so those fields come back missing for them. `build_covid_long_panel()`
  (`code/lib/covid_panel.R`) fills that gap by setting non-employed people's (`sempderived ==
  4`) missing `hours`/`wah` to `-8` (UKHLS's own "not applicable" code) rather than `NA`.
  Downstream, `make_workoutside_covid()`/`make_wfh_some_covid()` (`code/lib/work_groups.R`)
  treat any `hours<=0` as `0` — and `-8` satisfies that test just like a genuine `0` would.
  Net effect: a non-worker's raw `hours` value in the data is `-8`, but their
  `workoutside`/`wfh_some` outcome comes out `0`, exactly as if they'd reported working zero
  hours.
- **Couple-evolution tracking's three-way `NA`/`0`/`1`.** `still_with_base_partner`
  (`code/lib/future_outcomes.R`) and the analogous `observed_*_base_partner` flags
  (`code/lib/history.R`) use three distinct states rather than a binary: `NA` means "this
  person had no baseline partner to begin with" (not a couple), `0` means "was a baseline
  couple, but the link is broken/changed by this wave" (e.g. separation), and `1` means
  "still linked to the same baseline partner." This feeds the family-event outcomes
  (divorces, etc.) mentioned in [§1.4](#sec-1-4) — treating `NA` as "just missing" instead of "not
  applicable" would wrongly mix single people in with couples who separated.

<a id="sec-7"></a>

## 7. Data & licensing (full walkthrough)

<a id="sec-7-1"></a>

### 7.1 The datasets
This project uses three UK Data Service (UKDS) study families. Only the **EUL** edition is
currently in use; the pipeline already supports switching to **SL** via one flag ([§7.3](#sec-7-3)) once
that access is granted.

| SN | What it is | Role here |
|---|---|---|
| **SN 6614** | Understanding Society, **End User Licence (EUL)** main study | Default edition; condensed (`*_cc`) industry/occupation only |
| **SN 6931** | Understanding Society, **Special Licence (SL)** main study | Same files **plus** detailed 4/5-digit SIC (`jbsic07`) and SOC (`jbsoc10`) |
| **SN 6666** | Understanding Society **Special Licence, Local Authority District** | LAD identifiers for linking to local restrictions (IV design; see [§1.4](#sec-1-4)) |
| **SN 8644** | Understanding Society **COVID-19 Study** | The `ca`–`ci` COVID waves; available under **EUL** |

> Note: `code/lib/config.R` currently wires up SN 6614, SN 6931, and SN 8644. **SN 6666
> (LAD)** is part of the approved Special Licence application but is not yet wired into the
> config — adding it will be part of building the IV design. 

<a id="sec-7-2"></a>

### 7.2 Getting the data (UKDS)

1. Create your UKDS account and get invited/approved on the project — see [§8](#sec-8) for the full
   account, invitation, and paperwork sequence. **Do this before touching any data at all**,
   regardless of how the files themselves reach you. UKDS project approval is what makes you
   a licensed user of the data; that's required whether you get a fresh download or a
   teammate's already-synced Dropbox copy.

2. **For EUL data, join the shared Dropbox folder — don't download from UKDS.** The EUL data
   currently in use (SN 6614 main study, SN 8644 COVID study — [§7.1](#sec-7-1)) already lives in the
   team's shared Dropbox project folder, under
   `.../Dropbox/WFH_covid/UK project/understanding society uk all data/`. Once you're an
   approved project member (step 1), ask the project lead to add you to that shared Dropbox
   folder — **you do not need to download anything from UKDS yourself.**

   This project uses two machines:
   - **Coding machine** — your personal/work computer, running Claude Code/Codex and other AI
     tools to edit the repo. It can also be the machine you use to connect remotely to the run
     machine.
   - **Run machine** — the computer in Itay's office at Berglas, reached via TAU VPN and
     remote desktop, where the R pipeline actually executes against real data.

   On the **run machine**, use Dropbox's **Selective Sync** to bring down both the
   `understanding society uk all data` folder and the `division-of-labor` code folder —
   full sync of both is fine here, since no AI coding tool ever runs on this machine. Pick up
   the code with GitHub Desktop's "Add local repository" rather than cloning ([§12](#sec-12)). Select
   only these project folders, not your whole Dropbox account.

   On the **coding machine**, Selective-Sync the `division-of-labor` repo folder but exclude
   the data folder — see [§14](#sec-14) for exactly how.

   Once the data is synced on your run machine, skip to [§7.4](#sec-7-4) to point `code/lib/config.R` at
   your local copy before running any code.

3. **From scratch — only if you don't have Dropbox access, or once SL is granted:** download
   the relevant studies as **Stata (.dta)** files directly from UKDS. The pipeline reads
   `.dta` via the `haven` package. Expected raw files per wave:
   - Main waves: `{w}_indresp.dta`, `{w}_egoalt.dta`, `{w}_indall.dta`
     (e.g. `j_indresp.dta`). EUL and SL share identical file names and layout — SL just
     adds variables.
   - COVID waves: `{cw}_indresp_w.dta` (e.g. `cd_indresp_w.dta`).

4. Place the unpacked study folders **outside the git repo** (see [§7.4](#sec-7-4)) — the placement
   rules for EUL vs. SL data are in [§7.5](#sec-7-5). There is no shared-Dropbox shortcut for SL data; it
   only ever reaches you through the secure-machine process in [§9](#sec-9), once approved.

<a id="sec-7-3"></a>

### 7.3 EUL vs SL — the `DATA_LICENSE` switch
A single flag in `code/lib/config.R` selects the edition and rewires everything:

```r
DATA_LICENSE <- "EUL"   # or "SL"
```

- `"EUL"` (SN 6614): condensed industry/occupation; uses `jbsic07_cc` / `jbsoc10_cc`.
- `"SL"` (SN 6931): detailed codes; uses `jbsic07` / `jbsoc10`; key-worker and
  shutdown-sector groups are redefined from the detailed codes; **outputs are written to
  separate locations** so an SL run never overwrites EUL outputs.

The config derives the right variable names automatically:
```r
VAR_SIC <- if (DATA_LICENSE == "SL") "jbsic07" else "jbsic07_cc"
VAR_SOC <- if (DATA_LICENSE == "SL") "jbsoc10" else "jbsoc10_cc"
```
Most other variables share names across editions (SL incomes such as `fimngrs_dv` keep the
same name but are non-top-coded). See the project memory note on EUL vs SL for the detailed
mapping, and **verify the stored width of `jbsic07` on real SL data** when you first get it.

<a id="sec-7-4"></a>

### 7.4 Where things live on disk (paths)
All path logic is centralized in `code/lib/config.R`. **Do not hardcode machine-specific
paths anywhere else.** The config resolves paths per machine using the OS username
(`Sys.info()[["user"]]`), so each researcher's machine gets a branch:

- **Inputs (raw, confidential, outside repo):** `path_main_eul` (SN 6614),
  `path_main_sl` (SN 6931), `path_covid` (SN 8644). `path_main` follows `DATA_LICENSE`.
- **Outputs (derived, confidential, outside repo):** everything under `data_out_root`:
  - `der_path` → `derived/` (or `derived_SL/`): derived datasets (`.rds`)
  - `samples_path` → `samples/` (or `samples_SL/`): analytic samples (`.rds`)
  - `cache_path` → `cache/` (or `cache_SL/`): cached intermediates
- **Repo-safe outputs (inside repo, OK to sync):** `figures/` and `tables/`
  (SL run nests under `figures/SL/`, `tables/SL/`); policy inputs in `policies/`.

> **Before you start working with the code, edit `config.R` for your machine.** The config
> resolves these paths by matching your OS username (`Sys.info()[["user"]]`), so each new
> person/machine needs its own branch — the file already has one worked example (the
> `orishoham` block) to copy. Steps:
>
> 1. **Confirm the data actually synced** ([§7.2](#sec-7-2)): check that
>    `.../Dropbox/WFH_covid/UK project/understanding society uk all data/` exists on your
>    machine and contains `UKDA-6614-stata/` and `UKDA-8644-stata/` (and, once you have SL
>    access, `UKDA-6931-stata/`). If Dropbox hasn't finished syncing yet, wait for it before
>    editing anything.
> 2. **Find your OS username** — in R: `Sys.info()[["user"]]`.
> 3. **Add a branch to `code/lib/config.R`**, mirroring the existing `orishoham` block
>    exactly, just with your username and Dropbox path. There are **two** places to add it
>    (both already exist for `orishoham` — search the file for that name to find them).
>    - Near the top, right after `path_covid` is first set:
>      ```r
>      if (user == "<your-username>") {
>        dropbox_path <- "C:/Users/<your-username>/Dropbox/"
>        path_main_eul <- paste0(dropbox_path, "WFH_covid/UK project/understanding society uk all data/UKDA-6614-stata/stata/stata14_se/ukhls")
>        path_covid    <- paste0(dropbox_path, "WFH_covid/UK project/understanding society uk all data/UKDA-8644-stata/stata/stata13_se/")
>      }
>      ```
>    - Further down, next to the existing `data_out_root_eul` default:
>      ```r
>      if (user == "<your-username>") {
>        data_out_root_eul <- paste0(dropbox_path, "WFH_covid/UK project/understanding society uk all data")
>      }
>      ```
>    Only change the `C:/Users/<your-username>/Dropbox/` prefix if your Dropbox is installed
>    somewhere non-default.
>
>    **On the SL secure machine ([§9](#sec-9)), also add** `path_main_sl` and `data_out_root_sl` to the
>    same two blocks, pointing at your account's local disk — never Dropbox ([§7.5](#sec-7-5)):
>    ```r
>    path_main_sl     <- "C:/Users/<your-username>/sl_secure_data/understanding society uk all data/UKDA-6931-stata/stata/stata14_se/ukhls"
>    data_out_root_sl <- "C:/Users/<your-username>/sl_secure_data/understanding society uk all data"
>    ```
>    Leave these two out if you don't have SL access yet; the placeholder defaults are inert
>    while `DATA_LICENSE` stays `"EUL"`.
> 4. **Verify** by running, from the repo root:
>    ```r
>    source("code/run/00_check_inputs.R")
>    ```
>    Fix anything it flags and re-run until it prints `--- CHECK PASSED ---` before running
>    any other script.
>
> Keep `data_out_root` **outside** the git-tracked part of the repo (it already is — it lives
> under the Dropbox data folder, not under `code/`/`figures/`/`tables/`).

<a id="sec-7-5"></a>

### 7.5 Privacy constraints (non-negotiable) — the two tiers are different

The EUL and SL editions carry **different** handling obligations. Don't conflate them:

- **SL data (SN 6931, SN 6666 — detailed SIC/SOC, Local Authority District)** is the more
  restricted tier: it may **only** be stored and processed on the approved secure machine
  ([§9.1](#sec-9-1) — currently the TAU-managed desktop named in the licence application). It never goes
  onto a personal laptop, USB drive, personal cloud, or Dropbox folder, and never into an AI
  tool. This is a hard requirement of the Special Licence User Agreement.
- **EUL data (SN 6614, SN 8644)** is less restricted: the licence permits storing and
  processing it on an ordinary researcher machine, and in practice it lives in a Dropbox
  folder like any other project file. The binding constraint on EUL data is narrower but
  still absolute: **no AI tool may ever have read access to it.** See [§14](#sec-14) for how this is
  enforced in practice (the short version: the folder holding EUL raw/derived data is kept
  out of the Dropbox sync scope on whichever machine is used for AI-assisted coding).
- Raw micro-data and derived `.rds` files (either tier) **never go in the git repo** — they
  live outside the repo per [§7.4](#sec-7-4), regardless of which machine holds them.
- On **this** checkout (the one Claude Code/Codex work in) the licensed data are
  intentionally **absent for both tiers** — that's the point of the sync-exclusion setup in
  [§14](#sec-14). Do **not** try to run the full pipeline or probe data paths from here; this checkout
  is for code/docs only.
- **Claude and Codex already know not to run any R code in this project** — `CLAUDE.md` and
  `AGENTS.md` both instruct them not to run the pipeline or execute scripts against data.
  They may read and edit code, but all actual running of the pipeline is done by the RA
  directly, on the run machine ([§9](#sec-9)). This isn't something you need to re-explain to either
  tool; it's already part of their standing instructions for this repo, but you may need to enforce
  it or remind them. In any case they won't be able to run the code since the data is not available
  to them but it is wasteful for them to try.
- Only **repo-safe artifacts** may leave the secure/EUL environment into shared or public
  places: scripts, `figures/`, `tables/` fragments, `.tex`. Anything you export must be
  **aggregated and disclosure-safe** (no small cells, no raw SIC/SOC or fine geography) per
  the application's §2.7 and the UKDS Research Data Handling guide.

---

<a id="sec-8"></a>

## 8. Project administration & onboarding paperwork (do this before any data access)

<a id="sec-8-1"></a>

### 8.1 Project identity

- UK Data Service **project number 282609**, title **"Work from home in the UK"**.
- **Project lead:** Currently - Itay Saporta Eksten (this is a formality
  in the UK data Service and may change) — the project lead is the person who must invite you
  and who submits any changes to the project or team on the UKDS side.
- Outgoing team member: Ori Nahshon Shoham (the role being handed over).
- Approved project window: **2026-05-07 → 2029-12-31**.

<a id="sec-8-2"></a>

### 8.2 Get a UK Data Service account and be added to the project

This has to happen **before** any of the paperwork in [§8.3](#sec-8-3), and well before you can
download or see any data:

1. **Create your own UK Data Service account** at
   https://ukdataservice.ac.uk/register — use the email you want permanently associated
   with this project (institutional email is usually expected).
2. **Send that registered email to the current project lead** (Itay, or whoever holds the
   role at handover time) and ask them to add you to project **282609**.
3. **The project lead invites you** as a team member on the project through their UK Data
   Service account (Section 1.2 of the project application — "Research team" — lists
   everyone who is allowed to see the raw data; the lead adds new members there and on the
   UKDS website).
4. **Accept the invitation** when it arrives at your registered email, then complete the
   paperwork in [§8.3](#sec-8-3). You are not approved to access SL data until that paperwork is
   submitted and UKDS confirms approval in writing — don't download anything before that.

<a id="sec-8-3"></a>

### 8.3 Required forms

All forms are in `data_agreements/` (signed/submitted copies in `data_agreements/submit/`).
Order of operations, once you've been invited ([§8.2](#sec-8-2)):

1. **Complete the Special Licence *additional researcher* form** —
   `data_agreements/SpecialLicenceAdditionalResearcher.docx` (see Ori's filed example
   `SpecialLicenceAdditionalResearcher_Ori.docx`).
2. **Sign the Special Licence User Agreement** —
   `data_agreements/SpecialLicenceUserAgreement.pdf` (filed example:
   `submit/SpecialLicenceUserAgreement_Ori.pdf`). If home-working access is needed, complete
   the agreement's home-working **Appendix**.
3. **Read** the obligations you are agreeing to:
   - `data_agreements/cd171-researchdatahandling.pdf` (Research Data Handling & Security)
   - `data_agreements/cd137-enduserlicence.pdf` (End User Licence terms)
4. **Email everything to UKDS** (`help@ukdataservice.ac.uk` - probably Itay needs to do this)
   and **wait for written
   approval**. Do not download or handle SL data until approved. 
5. **At the end of the engagement:** complete `data_agreements/Data_Destruction_Form.docx`
   and securely delete the data per UKDS requirements.

The approved project application itself
(`data_agreements/submit/SpecialLicenceProjectApplication_revised.pdf`) is the canonical
description of what the project is permitted to do — read §2.1–2.7 of it.

---

<a id="sec-9"></a>

## 9. Running the code (the secure remote desktop for SL work)

This section covers the **Special Licence (SL)** secure machine. The data-licence obligation
itself doesn't require *this specific machine* for EUL work — the only real requirement
([§7.5](#sec-7-5), [§14](#sec-14)) is that EUL data sits on a machine untouched by AI agentic tools. In practice,
though, the run machine described here already satisfies that, and since you'll need it for
SL work anyway once that access comes through, it's simplest to just use it for EUL work too
rather than setting up (and maintaining) a separate personal EUL-only laptop. Doing the same
is recommended.

<a id="sec-9-1"></a>

### 9.1 What the environment is
Per the approved application, the SL data are **hosted on a Tel Aviv University-managed
desktop in Itay's locked office** and accessed **remotely via TAU's secure VPN** (two-factor
auth, personal accounts). The machine is BitLocker-encrypted, auto-locks on idle, and runs
anti-malware. No data may be copied off it. This is the "remote desktop" referred to
throughout this guide.

<a id="sec-9-2"></a>

### 9.2 Connection & access 

- You will need: a TAU account with VPN access + 2FA, and credentials/permission to the
  specific desktop that hosts the data. This is done through GlobalProtect.
- You will need to install Google Authenticator on your phone for the VPN
  connection and NetIQ Authenticator for the remote desktop connection.
- Just ask Ludmila (`ludmilap@tauex.tau.ac.il`) for help setting this up.
- Connect to the VPN first, then open a Remote Desktop session to the host. Close the
  session when you are done.
- Set the desktop to lock after 10 minutes and require a password to wake — this is **not**
  the default TAU configuration, so you'll need to change it yourself.

<a id="sec-9-3"></a>

### 9.3 Environment setup on the secure machine

- **Check R, RStudio, and GitHub Desktop are actually installed under your own Windows
  account** . Any git
  client works instead of GitHub Desktop if you prefer the CLI ([§12](#sec-12)).
- **R packages used by the pipeline** (install once):
  `tidyverse`, `haven`, `readxl`, `scales`, `forcats`, `modelsummary`, `glmnet`,
  `knitr`, `kableExtra`. (`data.table` appears only in exploratory scripts.)
  ```r
  install.packages(c("tidyverse","haven","readxl","scales","forcats",
                     "modelsummary","glmnet","knitr","kableExtra"))
  ```
- **Get the code onto the machine:** Selective-Sync the `division-of-labor` folder here
  alongside the data (see [§12](#sec-12) for the "Add local repository, not Clone" steps). The raw SL
  *data* still only ever lives in the approved local-disk location ([§7.5](#sec-7-5)) — this step is
  purely about the code.
- **Set paths:** add/confirm your machine's branch in `code/lib/config.R` ([§7.4](#sec-7-4)) so
  `path_main_*`, `path_covid`, and `data_out_root` point at the right places.

<a id="sec-9-4"></a>

### 9.4 Run workflow
Always open the project via the `.Rproj` file (not by opening R/RStudio separately and
navigating there) — this sets the working directory to the repo root, so relative paths like
`code/lib/config.R` resolve correctly.

1. **Pre-flight check** — confirms scripts, policy files, raw data, and output folders
   exist (and creates output folders):
   ```r
   source("code/run/00_check_inputs.R")
   ```
   It prints a per-wave completeness report and stops with a checklist if anything is
   missing. Fix issues, re-run until it prints `--- CHECK PASSED ---`.

2. **Run the whole pipeline** via the master script:
   ```r
   source("code/run/00_master.R")
   ```
   - Each stage runs in a **fresh environment** (`run_stage()` sources it with
     `local = new.env(parent = globalenv())`), so large datasets don't carry over in
     memory — every stage reads/writes from disk instead.
   - Toggle stages with the `RUN_*` flags at the top of `00_master.R`
     (e.g. `RUN_BUILD_DATA`, `RUN_DESCRIPTIVES`, `RUN_EVENT_STUDIES`, …).
   - Set `STOP_AFTER_EACH <- TRUE` to halt after each stage while debugging.

3. **Stage order** (also runnable individually, in this order):

   | Stage | Script | Produces |
   |---|---|---|
   | 0 | `00_check_inputs.R` | input validation |
   | 1 | `01_build_data.R` | baseline, history, COVID panel, future outcomes, couple files, samples (`.rds`) |
   | 2 | `02_make_descriptives.R` | COVID descriptive figures |
   | 2b | `02b_make_future_descriptives.R` | future/main-wave descriptives (flag-gated) |
   | 2c | `02c_sample_tables.R` | sample-composition tables + couple composition figures |
   | 2d | `02d_make_couple_treatment_descriptives.R` | couple-treatment figures (incl. work-status stacked bars) |
   | 2e | `02e_make_couple_baseline_descriptives.R` | baseline-distribution figures for `couples_graphs_short.tex` |
   | 3a | `03a_make_couple_treatment_event_studies.R` | event-study figures + saved results |
   | 3b | `03_models_workoutside.R` | `tables/workoutside_industry_comparison.tex` |
   | 4 | `04_lasso_workoutside.R` | exploratory lasso outputs |
   | 5 | `99_session_info.R` | reproducibility metadata |

4. **Getting outputs out (egress).** Only commit/export the repo-safe, disclosure-checked
   artifacts: scripts, `figures/`, `tables/`, `.tex`. The `.rds` files under `data_out_root`
   and all raw data **stay on the secure machine**. Push code/figures/tables changes to
   GitHub from the secure machine (or copy only those files), never the data.

---

<a id="sec-10"></a>

## 10. Code & coding conventions

- **Staged pipeline, isolated environments.** Stages communicate **through disk**, not
  memory. If a stage needs a previous stage's output, it reads the `.rds` from
  `der_path`/`samples_path` — it does not assume in-memory objects exist.
- **Centralize configuration.** All paths, flags, wave lists, and the licence switch live in
  `code/lib/config.R`. Every stage `source()`s it. Don't scatter machine-specific paths.
- **Functions belong in `code/lib/`; `code/run/` scripts stay clean.** This is a hard
  convention in this repo, not just a suggestion. A `code/run/*.R` script should read as
  orchestration — `source()` the relevant `code/lib/` files, load data, call functions, save
  outputs — not define new functions inline. If you catch yourself writing `function(...)`
  inside a run script, stop and move it to the matching `code/lib/` file (or a new one)
  instead, even if only that one run script calls it today. Exceptions should be rare and
  genuinely trivial — e.g. a tiny one-line local closure used once, right where it's used —
  not a pattern to copy for anything with real logic in it. Keeping this boundary is what
  makes the run scripts in [§5.1](#sec-5-1) readable top-to-bottom and keeps the actual logic reusable
  and easy to find.
- **Treat `figures/*` and `tables/*.tex` as generated outputs**, not hand-edited source.
  Slide decks reference them by exact path, so **preserve `.rds` names, figure stems, and
  TeX asset paths** unless you are deliberately migrating the pipeline (and then update the
  consuming `.tex`).
- **Naming / wave conventions.**
  - COVID waves: `ca`–`ci`. Future/main follow-up waves: `j`–`o`. History candidate waves:
    `a`–`k`.
  - **Baseline** = each person's **2019** interview from main waves **I/J/K** (the only
    waves whose fieldwork overlaps 2019), preferring the latest wave (K > J > I) if more
    than one falls in 2019 — not simply "most recent interview" regardless of year ([§2.2](#sec-2-2)).
  - **Grouping is by *baseline* SIC/SOC**, not post-treatment status (`code/lib/work_groups.R`).
- **Stick to the approved plan.** Do **not** add design choices that aren't agreed —
  including seemingly minor ones (trimming/filtering observations, changing plot defaults).
  Raise any deviation with the project lead **before** implementing. (This is also encoded in
  `CLAUDE.md` and the project memory.)
- **R style.** Match the surrounding code: tidyverse idioms, `suppressPackageStartupMessages`
  around `library()` blocks, comment density similar to existing files.

---

<a id="sec-11"></a>

## 11. Current outputs & where they're consumed

**Figures** are written under `figures/` in organized subfolders defined by the `fig_path_*`
variables in `config.R` (e.g. `figures/descriptives/covid/`, `figures/sample_composition/`,
`figures/couple_treatment/…`, and `figures/couple_treatment/baseline_distributions/`). SL
runs nest the whole tree under `figures/SL/`.

**LaTeX table fragments** are written under `tables/` (SL → `tables/SL/`) — e.g. the
`sample_table_*` family and `workoutside_industry_comparison.tex`. These are `\input{}` into
the decks; treat them as generated.

**TeX consumers** (which deck uses which outputs):

| TeX file | What it is | Fed by |
|---|---|---|
| `meeting_slides_descriptive_analysis.tex` | main descriptive deck (tolerates missing assets via placeholders) | 02, 02b, 02c |
| `couples_graphs_short.tex` | **the most up-to-date couple-treatment deck.** Wife-key treatment only; each outcome prefixed by a variable-definition slide and a baseline-distribution slide; includes the 2018-baseline-fallback appendix ([§2.2](#sec-2-2)) | 02d, 02e, 03a |
| `couples_graphs.tex` (→ `couples_graphs.pdf`) | Similar in spirit but **longer and covers both treatments** (wife-key and husband-shutdown) with event studies + balance tables for each. Kept in parallel with `couples_graphs_short.tex` rather than superseded by it, but **updated less often** — treat it as possibly slightly behind: it doesn't have the per-outcome variable-definition slides, and may be missing recent outcome/appendix additions that only landed in the short deck. Check `couples_graphs_short.tex` first when the two seem to disagree. | 02c, 02d, 03a |
| `meeting_slides.tex` | older, lighter descriptive deck | earlier descriptives |
| `method.tex` | rough methodology / brainstorming notes | — |
| `main.tex` | stub, not the current writing target | — |
| `grants/Falk/…tex`, `grants/Sapir/…tex` | proposals (broader framing) | selected figures |

All of these decks are internal working documents for team meetings, not a polished
manuscript — how tightly `couples_graphs.tex` is kept in sync with `_short` is a team call
to make together, not a strict requirement.

---

<a id="sec-12"></a>

## 12. Git workflow (from scratch)

This repo has **two remotes**: `origin` (GitHub) and `overleaf` (Overleaf — see [§13](#sec-13)).

### Before you start (prerequisites)

If any of these already apply to you, skip ahead — otherwise do them in order:

1. **No GitHub account?** Create one for free at https://github.com/join. Any email is
   fine; it doesn't need to be institutional.
2. **Get added to the repo.** Email **Ori** at `ori.shoham1@gmail.com` or
   `orins@mit.edu` with your GitHub username, and ask to be added as a collaborator on
   `Ori-Shoham/division-of-labor`. You won't be able to push or pull until this happens —
   do this early, since it depends on Ori actually seeing the email.
3. **No git client installed?** Install **GitHub Desktop**
   (https://desktop.github.com) — the simplest option, and what the rest of this guide
   assumes — or any git client/CLI you already prefer. If you're not sure how to install or
   configure one, your AI coding tool (Claude Code, Codex, etc.) can walk you through it
   step by step; just ask it.

Once all three are done, set up the repo itself on your machine:

**One-time setup: use "Add local repository", not "Clone".** The `division-of-labor` repo is
Dropbox-synced on every machine on this project, including the run/SL machine ([§9](#sec-9)). It
therefore already arrives fully formed — `.git/` and full history included — as soon as
you're added to the shared Dropbox folder and it finishes syncing.

1. Get added to the shared Dropbox folder; wait for the sync to fully finish (check that
   `.git/` itself is present, not just the visible files — Dropbox can take a while on a
   repo this size).
2. In **GitHub Desktop**: **File → Add local repository...** (*not* "Clone repository...")
   and point it at the already-synced folder — this recognizes the existing repo in place,
   with no download or re-fetch. Using the git CLI instead: just `cd` into the synced folder
   (`git status` will work immediately); run `git config user.name`/`user.email` if this is a
   new machine.
3. Confirm `git status` / `git log` look sane, and that you can actually push (you should
   already be a collaborator per prerequisite #2 above) before doing anything else.

Only fall back to a plain `git clone` if a machine has no access to the shared Dropbox
folder:
```bash
git clone https://github.com/Ori-Shoham/division-of-labor.git
cd division-of-labor
git config user.name  "Your Name"
git config user.email "you@example.com"
```

Avoid running git commands from two machines against their own local Dropbox copies of this
folder at the same time — that's the one way Dropbox and git can conflict with each other.
When a role passes from one person to another, the outgoing person should stop
committing/pulling once the incoming person is confirmed working; passive Dropbox
syncing/browsing afterward is harmless.

**Everyday habit: commit and push regularly.** Most of you will be working in GitHub
Desktop, not the command line — the exact clicks don't matter as much as the habit itself.
Every time you finish a meaningful chunk of work (a script edit, a new figure, a fixed bug),
stage it, write a short commit message describing what changed, and push. Don't let changes
pile up uncommitted for days — small, frequent commits are much easier for anyone (including
your future self, or the RA after you) to follow than one giant commit. Pull before you start
a new session too, so you're never working from a stale copy. If you already know git well
enough to prefer the CLI (`git status`/`add`/`commit`/`push`/`pull`), go ahead — the habit
matters more than the tool.

**Dropbox caveat (important here).** The repo lives inside Dropbox, so `git status` often
shows **noise**: timestamp churn, sync conflict files (`*~$*`, `* (1).*`), and re-touched
generated outputs under `figures/`/`tables/`. **Inspect generated-file diffs before staging**
— a changed figure is only meaningful if you intended to regenerate it. Make **small,
focused commits**. A missing generated file in `git status` does **not** mean "regenerate
everything" — check whether Dropbox or a cleanup moved it first.

**Branches.** `main` is the working branch. You'll also see an `overleaf-backup` branch and
dated `overleaf-YYYY-MM-DD-…` branches in the repo's history — these are leftovers from an
earlier, manual approach to Overleaf syncing, not something the current process creates or
uses ([§13](#sec-13)'s `overleaf integration/` scripts track sync state differently, via a git ref, not
branches). Don't develop on any of them; they're historical, not active.

---

<a id="sec-13"></a>

## 13. Overleaf workflow (writing ↔ git)

The `.tex` writing is mirrored to **Overleaf**. Normally Overleaf offers a one-click
**GitHub Sync** integration for exactly this — but this project is **too heavy** for it
(too many/too large generated files — all the figures, tables, etc. — for Overleaf's
built-in sync to handle). So instead of GitHub Sync, this repo talks to Overleaf directly
over **git**, through a second remote:

```
overleaf  https://git.overleaf.com/<project-id>   (fetch/push)
```
(`origin` = GitHub; `overleaf` = the Overleaf project's own git endpoint, separate from
GitHub. Overleaf's `master` branch holds the writing content.)

**Getting access:** ask **Oren** (`orendanieli@gmail.com`) to add you as a collaborator on
the Overleaf project — you'll need this before the scripts below can authenticate for you.

**You do not need to run any git/bash commands for this yourself.** Two ready-made
scripts in `overleaf integration/` handle the entire sync in each direction — just run
them (double-click the `.bat` file, or run it from Explorer/PowerShell; no arguments
needed):

- **`overleaf integration/fetch_and_merge_from_overleaf.bat`** — pulls whatever co-authors
  changed on Overleaf since the last sync and commits it into your current local branch as
  "Import Overleaf changes." Run this when you know someone edited the deck/proposal text
  in the Overleaf web editor and you want those edits locally.
- **`overleaf integration/push_to_overleaf.bat`** — pushes your current committed files to
  Overleaf as a single small commit, **without** sending the full GitHub history (that's
  the "too heavy" part GitHub Sync can't do). It deliberately leaves `couples_graphs.pdf`
  out of what it sends to Overleaf. Run this after you've regenerated figures/tables or
  edited `.tex` locally and want Overleaf's copy to catch up.

**Rules the scripts enforce for you** (so you don't have to remember them):

- Both scripts **require a clean working tree** — commit your changes in GitHub Desktop
  first. If anything is uncommitted, the script stops and tells you to commit or discard it.
- **Order matters:** if Overleaf has changes you haven't imported yet, the push script
  refuses and tells you to run the fetch/merge script first. So the safe habit is simply:
  **fetch-and-merge before you push**, every time.
- If a script fails with a 403 error, it's almost always stale saved credentials — delete
  the saved `git.overleaf.com` entry in Windows Credential Manager and re-run.
- If the push script fails with "HTTP 413," the committed file tree is still too large for
  Overleaf — that means something big got added that shouldn't be tracked; ask before
  forcing it through.

The fetch/merge script already commits the imported Overleaf changes locally for you — after
it finishes, just push that commit to GitHub from GitHub Desktop as usual ([§12](#sec-12)). The push
script doesn't touch your local commits at all; it only sends your already-committed files
to Overleaf.

---

<a id="sec-14"></a>

## 14. AI coding tools

**Use AI for coding on this project — and use it as a system installed on your computer,
not a chat window.** This repo is large, interconnected, and full of conventions (naming,
the run/lib split in [§10](#sec-10), the pipeline structure in [§5](#sec-5)); an *agentic coding tool* that runs
directly in the repo — Claude Code or Codex, both covered below — can read `CLAUDE.md`/
`AGENTS.md` once, keep that context across a session, actually open and edit the real files,
run checks, and follow this project's guardrails automatically. A general AI chat window
(ChatGPT, Claude.ai, etc. in a browser tab) can't do any of that: you'd be manually pasting
code back and forth, it has no persistent memory of this repo's conventions, and — most
importantly here — it's far too easy to accidentally paste something you shouldn't, like
real values from restricted data, into a chat that isn't bound by this repo's guardrails at
all. Install one of the tools below and point it at the repo; don't default to a chat tab.

**Which tool, and why.** Ori originally worked with **Codex**, then mostly switched to
**Claude Code** — but that switch was practical, not a verdict on Codex: the university's
ChatGPT/Codex account kept running out of tokens quickly, which made Claude Code more
usable day-to-day. Both Codex and Claude Code worked fine on this project. Pick whichever
one you have reliable access to (or use both). Neither needs setup work to get started:
`CLAUDE.md` and `AGENTS.md` already exist at the repo root for exactly this purpose — Claude
Code reads `CLAUDE.md`, Codex reads `AGENTS.md` (the two are kept as duplicates of each
other; see the note at the top of `AGENTS.md`).

### Claude Code

- **Install / auth:** Claude Code is Anthropic's CLI (also available as desktop/IDE/web).
  Install per the official docs and sign in with the project's Anthropic account.
- **You don't need to configure anything else to get project context into it.** `CLAUDE.md`
  (repo root) is loaded automatically and encodes the repo layout, run order, data-privacy
  rules, and conventions — keep it in sync with this guide when the pipeline changes. It also
  has features like persistent memory and a plan mode (propose an approach before editing —
  worth using for anything non-trivial); Claude Code's own docs/`/help` cover how those work
  in more depth than this guide needs to.

### Codex

- **Install / auth:** Codex is OpenAI's CLI coding agent. Install per the official docs and
  sign in with whichever OpenAI/ChatGPT account you have access to. It reads `AGENTS.md` for
  the same project context Claude Code gets from `CLAUDE.md`.

### Guardrails for any AI tool here (critical — applies regardless of which you use)

As established in [§7.5](#sec-7-5): **SL data never touches a machine that runs AI tools at all**
(enforced by the TAU secure desktop's physical/network isolation, [§9](#sec-9)); **EUL data may live
on an ordinary laptop, but only if that laptop's AI-tool sync scope excludes the data
folder.** The mechanics of that EUL exclusion, specific to this checkout:

- Dropbox's **Selective Sync** is what implements the exclusion: the project Dropbox
  folder syncs normally, but the specific "understanding society uk all data" subfolder
  (the `path_main_*` / `path_covid` / `data_out_root` targets from [§7.4](#sec-7-4)) is deselected in
  Selective Sync on this machine, so it simply doesn't exist on disk here — an AI tool has
  no path to read even if asked. That's why this checkout has no data present, and why
  `00_check_inputs.R` will report the data roots missing if you run it here (expected —
  don't "fix" it).
- **Practical setup: keep the two roles on separate machines** — the coding machine and
  run machine described in [§7.2](#sec-7-2). Don't try to toggle one machine between the two states;
  that's exactly the kind of manual step that eventually gets forgotten.
- **Selective Sync generally, not just for the data folder:** on either machine, only sync
  the project folders you actually need, not your entire Dropbox account — an unrelated
  full-account sync wastes local disk space and makes it harder to reason about what an AI
  tool can see.
- If you set up a new coding machine, replicate the above: let the repo folder sync, but
  exclude/unsync the external data folder(s) via Selective Sync before installing or
  running any AI tool there. Do this *before* pointing an agent at the repo, not after.
- **Never paste licensed data (SL or EUL), raw variable extracts, or file contents from the
  data folders into an AI tool's chat**, even from a machine that does have access (e.g.
  while debugging on the SL desktop, don't copy data into a browser-based AI tool).
- On this checkout, since the data is absent, **do not ask the agent to run the pipeline or
  probe data paths** to "see" the data — it can't, and shouldn't be made able to. Use code
  inspection and the committed figures/tables instead.
- Make sure whichever tool you use actually follows [§10](#sec-10)'s "stick to the approved plan" rule
  — it shouldn't introduce unrequested design changes without your sign-off.

---

<a id="sec-15"></a>

## 15. Where things stand & open project-level next steps

*Inferred from recent git history and the current outputs.*

- The **EUL pipeline is the mature path**: the 2019-only baseline ([§2.2](#sec-2-2)), couple panels,
  sample tables, couple-treatment descriptives, baseline-distribution figures, and
  event-study analogs all run and feed the decks (`couples_graphs.tex`,
  `couples_graphs_short.tex`, `meeting_slides_descriptive_analysis.tex`).
- Recent work (see `git log`) has been on **baseline distribution figures**, the **2018
  baseline-fallback exploration** ([§2.2](#sec-2-2), `code/explore_baseline_year_2018_2019.R`, results
  already in `couples_graphs_short.tex`'s appendix), **winsorizing**, **event-study
  updates**, and **slide/Overleaf cleanup**.
- **Open next steps for the project** — these are decisions and direction the research
  team (Itay, Oren, Analia — [§16](#sec-16)) will set, not a checklist for a new RA to work through
  solo. The team recruits and meets regularly with whoever holds this role and will
  instruct you on which of these (if any) to pick up and when:
  1. Whether to promote the **2018 baseline fallback** from exploration to the production
     baseline, given the observation-gain figures already produced.
  2. Moving from EUL to **SL** once the Special Licence data is in hand: set `DATA_LICENSE
     <- "SL"`, verify `jbsic07`/`jbsoc10` widths, re-derive key-worker/shutdown groups from
     detailed codes, and re-run the pipeline into the `*_SL` output trees.
  3. Wiring in **SN 6666 (LAD)** and the **IFS restrictions linkage**, then building the
     **IV design** (realised work-location states instrumented by pre-COVID exposure ×
     local restrictions) described in [§1.4](#sec-1-4).
  4. Expanding event-study outcomes (housework/childcare, well-being, family events) and
     the youngest-child heterogeneity cut.

---

<a id="sec-16"></a>

## 16. Contacts, resources & glossary

**People**

- Project lead: **Itay Saporta Eksten** — `itay.saportaeksten@manchester.ac.uk`.
- Research team (recruit and regularly meet with whoever holds this RA role, and set
  direction on the open next steps in [§15](#sec-15)): **Itay Saporta Eksten**, **Oren Danieli**
  (`orendanieli@gmail.com`), **Analia Schlosser**.
- Outgoing RA (handover): **Ori Shoham** — `ori.shoham1@gmail.com` / `orins@mit.edu` /
  GitHub `Ori-Shoham`.

**Resources**

- UK Data Service: https://ukdataservice.ac.uk · `help@ukdataservice.ac.uk`
- Understanding Society (study docs/variable search): https://www.understandingsociety.ac.uk
- GitHub repo: https://github.com/Ori-Shoham/division-of-labor
- Overleaf: the `overleaf` git remote's project — ask **Oren** (`orendanieli@gmail.com`)
  for access ([§13](#sec-13)).
- ONS key-worker reference tables; IFS BN278 shutdown sectors (Joyce & Xu 2020) — copies and
  crosswalks in `policies/`.

**Glossary**

- **UKHLS / Understanding Society** — the UK Household Longitudinal Study; a large, partner-
  linked household panel survey.
- **Wave** — one round of data collection. Main waves are letters (`a`, `b`, …); COVID waves
  are `ca`–`ci`.
- **EUL / SL** — End User Licence (coarser, SN 6614) vs Special Licence (detailed SIC/SOC and
  LAD, SN 6931/6666). Selected by `DATA_LICENSE`.
- **SIC / SOC** — Standard Industrial / Occupational Classification codes (industry / job).
- **Key worker** — ONS-defined essential-sector worker expected to work outside the home.
- **Shutdown sector** — IFS-defined sector forced to close in early COVID.
- **Baseline** — each person's **2019** interview from main waves I/J/K (the latest of I/J/K
  that happened to fall in 2019 for that person), not simply their most recent interview.
- **Event study** — DiD specification tracing outcome differences by event time relative to
  COVID onset, treated vs comparison couples.

---

*Maintenance: when you change the pipeline, update this file together with `CLAUDE.md` and
`AGENTS.md`. Keep secrets (hosts, credentials, share links) out of this committed file —
point to "obtain from Ori / TAU IT" instead.*
