# ai-docs (lowercase)

Project-local **session knowledge** for PodleRex: sanitized, traversable Markdown written by the `go-next` skill.

## Case distinction

| Path | Role |
|------|------|
| `ai-docs/` | **Canonical** go-next output (this tree). |
| `AI-docs/` | Pre-existing placeholder directory in the repo. **Preserved.** Do not rename, delete, or merge destructively. It is not the go-next target. |

## Layout

```text
ai-docs/
  README.md          this file
  index.md           backlinks / session index
  sessions/          sanitized narrative reports
  evidence/          screenshots and other provenanced artifacts
  .private/          gitignored raw captures and jobs (never publish by default)
```

## Privacy

- Committed docs are **sanitized reports**, not raw session transcripts.
- Raw Pi JSONL slices live only under `.private/` (ignored by git).
- Redact secrets and private external home paths before commit.
