---
name: go-next
description: >-
  Session-boundary documentation for PodleRex only. Run at chat wind-down instead
  of a bare compact/clear when project knowledge should land in lowercase ai-docs/.
  Captures an immutable bounded Pi session snapshot first, then delegates a
  documentation worker via podlesp fm-brief/fm-spawn (durable backlog), so the
  captain can open a new session immediately. Use on /go-next, go next, session
  doc flush, or when asked to retain this chat as traversable project knowledge.
---

# go-next (PodleRex pilot)

Minimal session-boundary sync for **this repo only**. Inspired by the upstream ObbyVault `go-next` skill (`/home/podles/fleet/firstmate/projects/go-next`, read-only reference) but **not** that vault pipeline: no whole-vault harvest, no language transformer, no tag pass.

**Outputs:** sanitized narrative Markdown under project `ai-docs/` (lowercase).  
**Private:** raw session slices under `ai-docs/.private/` (gitignored).  
**Not:** `AI-docs/` (legacy empty placeholder — leave it; see `ai-docs/README.md`).

## Install

### In PodleRex (canonical)

Skill path (project-scoped, auto-discovered by Pi when cwd is this repo):

```text
.pi/skills/go-next/SKILL.md
```

Invoke:

```text
/skill:go-next
```

or ask to flush the session into `ai-docs/`.

### podlesp secondmate pointer (private home — supervisor installs)

Prepare artifact in-repo (do not write outside the worktree from crewmates):

```text
deploy/secondmate-go-next-pointer/
```

Supervisor install step (exact):

```bash
# From podlesp secondmate home (FM_HOME):
mkdir -p "$FM_HOME/.agents/skills"
cp -a /path/to/PodleRex/deploy/secondmate-go-next-pointer \
  "$FM_HOME/.agents/skills/go-next"
# Or symlink the pointer dir. Point body still loads the project skill under
# $FM_HOME/projects/PodleRex/.pi/skills/go-next/SKILL.md
```

See `deploy/secondmate-go-next-pointer/INSTALL.md`.

## Pipeline (order is the safety contract)

1. **Capture (blocking, same agent, before any reset-safe line)**  
   ```bash
   SNAP=$(.pi/skills/go-next/scripts/capture-source.sh \
     --project-root "$(git rev-parse --show-toplevel)")
   ```
   Uses `PI_SESSION_FILE` / `PI_SESSION_ID` when present. Refuses non-PodleRex scope.  
   Writes immutable `ai-docs/.private/snapshots/<capture_id>/`. **No overwrite.**

2. **Package durable job**  
   ```bash
   JOB=$(.pi/skills/go-next/scripts/prepare-job.sh --snapshot "$SNAP")
   ```
   Job holds snapshot pointer + worker prompt. Worker must not need parent chat.

3. **Delegate via Firstmate (secondmate context)** — not an untracked subagent:  
   ```bash
   # FM_HOME = podlesp secondmate home
   bash "$JOB/SPAWN_COMMANDS.sh"
   ```
   Default spawn profile: **Pi**, model **`xai/grok-4.5`**, effort **`high`**, mode **`local-only`**.  
   If `fm-brief`/`fm-spawn` unavailable in this shell, print `$JOB/SPAWN_COMMANDS.sh` and the job path for the secondmate to run; still do not skip capture.

4. **Reset-safe acknowledgement (only after step 1 succeeded)**  
   End with exactly:
   ```text
   go-next: capture <capture_id> sealed. Job <task_id> queued for ai-docs worker. Safe to open a new session / compact / clear this chat. Limits: docs may still be writing; raw snapshot is private; not a full history archive.
   ```

## Report bar

Worker follows `references/worker-prompt.md` + `references/report-outline.md`.

Metadata must include report timestamp+timezone, source session id, observed start/end/cutoff, elapsed only from known timestamps, coverage warning, active time distinct and usually `unknown`. Never invent session length.

## Rules

- PodleRex-relevant source only (this home / this project path). No main-home unrelated harvest.
- Capture before ack. Worker independence from parent session lifetime.
- Duplicate invocation → new capture_id and new report file; never overwrite prior snapshot or report.
- Sanitized report ≠ private snapshot. Do not publish raw transcripts by default.
- Redact secrets and private external home paths in committed docs.
- No hardware ops, no firmware changes, no destructive rename of `AI-docs/`.

## Scripts

| Script | Role |
|--------|------|
| `scripts/capture-source.sh` | Immutable bounded session capture + metadata |
| `scripts/prepare-job.sh` | Durable job + `SPAWN_COMMANDS.sh` (`--spawn` optional) |
| `scripts/redact.sh` | Shared redaction helpers |

## Tests

```bash
bash tests/go-next-test.sh
```
