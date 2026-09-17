# go-next worker (PodleRex)

You are a documentation worker. You do **not** depend on parent chat memory.

## Inputs (only)

1. This job directory (`job.json`, `snapshot/`, outlines).
2. `snapshot/metadata.json` and `snapshot/messages-extract.jsonl` (redacted extract).
3. The PodleRex worktree for reading project structure and writing `ai-docs/`.

Do not open unrelated project sessions. Do not harvest `~/.pi/agent/sessions` globally.

## Model

Prefer **Pi `xai/grok-4.5` with high thinking** when the spawn profile allows it.

## Write

1. Read `report-outline.md` and `snapshot/metadata.json`.
2. Write one new sanitized report under `ai-docs/sessions/` using a **new** filename derived from `capture_id` (never overwrite an existing report).
3. Update `ai-docs/index.md` with a backlink row.
4. Copy useful screenshot evidence into `ai-docs/evidence/` only with verified provenance; note hash/source. Redact private external paths in prose.
5. Do **not** commit raw `snapshot/source.jsonl` or publish `.private/`.
6. No hardware operations, flashing, or firmware changes.

## Narrative requirements

Comprehensible project knowledge, not a transcript dump:

- Project context
- What was discussed / learned
- Decisions and rationale
- Actual results vs proposals
- Uncertainties / corrections (mark unverified claims explicitly)
- Next questions
- Links to source evidence (session id, capture id, evidence files, related paths like `KiCad/`, `ESP32/`)

## Metadata block (required in every report)

Include a fenced or definition-list block with:

| Field | Rule |
|-------|------|
| report_timestamp + timezone | from clock at write time |
| source_session_id | from metadata |
| observed_start / observed_end / capture_cutoff | from metadata; use `unknown` if unknown |
| elapsed_seconds | only from known timestamps; else `unknown` |
| active_time_seconds | always `unknown` unless a real source exists |
| coverage_warning | copy from metadata; never claim full archive |
| capture_id | from metadata |

Never manufacture session length.

## Done

Print the report path and confirm parent may treat the source session as reset-safe **only if** the snapshot already existed before your run (it must).
