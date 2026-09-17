# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## Session documentation (go-next)

- Skill: `.pi/skills/go-next/SKILL.md` — session-boundary docs into lowercase `ai-docs/` (preserve legacy `AI-docs/`; do not rename).
- Capture must finish before any reset-safe ack; workers use sealed snapshots under `ai-docs/.private/` (gitignored), not parent chat memory.
- Secondmate pointer install artifact: `deploy/secondmate-go-next-pointer/` (supervisor copies into `$FM_HOME/.agents/skills/go-next`).
- Tests: `bash tests/go-next-test.sh`
- Current product focus (captain): piezo sensing + parallel analog frontends for ESP32-S3 ADC; existing firmware is not the primary circuit guide. See `ai-docs/`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
