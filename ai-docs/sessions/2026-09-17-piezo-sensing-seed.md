# Piezo sensing session knowledge (seed)

## Metadata

- report_timestamp_utc: 2026-09-17T20:30:00Z
- report_timezone: UTC (+0000)
- source_session_id: **unknown** (seeded from captain-supplied context during the go-next tooling pilot; no sealed live capture id for the prior circuit chat)
- capture_id: **none — seed example**
- observed_start_utc: **unknown**
- observed_end_utc: **unknown**
- capture_cutoff_utc: **unknown** (not a live capture)
- elapsed_seconds_from_known_timestamps: **unknown**
- active_time_seconds: **unknown**
- coverage_warning: This is a **seeded** documentation example from explicit captain/user context in the go-next pilot task. It is **not** a full session archive, **not** a sealed go-next capture, and **not** a technical electrical sign-off. Searchable agent history may exist elsewhere; completeness and retention are unknown.
- scope: PodleRex-only (podlesp secondmate project context)

## Project context

PodleRex is the hardware/firmware workspace for the captain's piezo-oriented work. **Current center of gravity (captain):** piezo sensing with **parallel analog frontends** intended for **ESP32-S3 ADC** acquisition. Existing firmware trees under `ESP32/` (including `ESP_piano` and `legacy/`) are **not** the primary guide for this circuit-understanding thread.

Captain goal: understand **each circuit component** and retain sessions as **traversable project knowledge** (this `ai-docs/` tree), rather than losing context when opening a new chat.

## Discussed and learned

- Documentation tooling should land readable narrative in lowercase `ai-docs/`, with date/session/length metadata when a real capture exists.
- A screenshot was supplied for the frontend/schematic discussion:
  - filename `paste-20260917T182006094Z-40b0440a5f594a2592072e9b106bc194.png`
  - preserved under [`../evidence/`](../evidence/) with hash noted in `evidence/README.md`
- **Unverified — prior assistant circuit explanation:** generic intended behavior for divider / clamp / buffer stages must **not** be treated as verified actual wiring.
- **Open schematic concerns (from captain/pilot context, not re-diagnosed here):**
  - possible duplicate or confusing `ESP32_GPIO_34` net usage in the discussed drawing
  - GPIO 34 class pins called out as **invalid as ESP32-S3 ADC inputs** in that discussion (needs confirmation against the S3 datasheet and the actual netlist)
  - possible wiring shorts — **unverified**; do not invent electrical evidence
- Repo check during pilot (for orientation only): `KiCad/firstTime/firstTime.kicad_sch` contains a global label `ESP32_GPIO_34` (string search found one label occurrence in the current file). That does **not** by itself confirm or refute multi-net or short issues visible on a screenshot — treat visual/screenshot review as still open.
- Earlier assistant messaging that "there is no transcript logging" was **overstated**. Searchable history exists in agent session stores; **completeness and retention remain unknown**.

## Decisions and rationale

- **Firmware is not the primary guide** for the present circuit-learning thread (captain).
- **go-next pilot** documents sessions into `ai-docs/` so the captain can reset/open a new session without losing narrative knowledge.
- This seed marks uncertainties explicitly rather than laundering them into facts.

## Results vs proposals

| Item | Status |
|------|--------|
| Understand each frontend component | **Open** — not completed in this seed |
| Verified net-by-net ADC mapping to ESP32-S3 | **Open** |
| go-next tooling to retain sessions | In progress via pilot (tooling PR), separate from circuit sign-off |
| Treat prior assistant divider/clamp/buffer write-up as fact | **Rejected** until verified |

## Uncertainties and corrections

- No claim is made that the screenshot matches the on-disk KiCad file byte-for-byte with the captain's latest edits.
- No claim is made about measured voltages, pin mux, or ADC channel validity without datasheet + schematic correlation.
- Private absolute paths to paste staging are omitted on purpose; use evidence filenames + hash.
- Session length for the pre-pilot circuit chat is **unknown** — do not invent it.

## Next questions

1. For each parallel frontend channel: what are the exact stages (series R, divider, clamp, buffer/op-amp, DC bias), and which ESP32-S3 ADC-capable GPIO does each land on?
2. Does the KiCad netlist (ERC/net highlight) show any unintended shorts or reused ADC-invalid pins?
3. Should `ESP32/ESP_piano` ADC sampler code be read only as a software reference after the analog nets are verified?
4. What retention exists for prior PodleRex agent sessions the captain cares about, and should any be captured retroactively with go-next (bounded, explicit ids only)?

## Evidence and backlinks

- Screenshot: [paste-20260917T182006094Z-40b0440a5f594a2592072e9b106bc194.png](../evidence/paste-20260917T182006094Z-40b0440a5f594a2592072e9b106bc194.png) · [evidence README](../evidence/README.md)
- Index: [../index.md](../index.md)
- Schematic tree: `KiCad/firstTime/`
- Firmware (non-primary): `ESP32/ESP_piano/`, `ESP32/legacy/`
- Skill: `.pi/skills/go-next/SKILL.md`
