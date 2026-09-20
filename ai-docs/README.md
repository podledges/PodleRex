# ai-docs (lowercase)

Project-local **session knowledge** for PodleRex: sanitized, traversable Markdown written by the `go-next` skill, plus concise research companions.

## Case distinction

| Path | Role |
|------|------|
| `ai-docs/` | **Canonical** go-next output and research companions (this tree). |
| `AI-docs/` | Pre-existing placeholder directory in the repo. **Preserved.** Do not rename, delete, or merge destructively. It is not the go-next target. |

## Layout

```text
ai-docs/
  README.md                  this file
  index.md                   backlinks / session index
  piano-transcription.md     research companion (not a go-next session)
  sessions/                  sanitized narrative reports
  evidence/                  screenshots and other provenanced artifacts
  .private/                  gitignored raw captures and jobs (never publish by default)
```

## Research companions

- [Piano audio transcription](piano-transcription.md) — concise companion for PodleRex piezo / ESP32-S3 exploration. Canonical four-report vault lives in **PodlESP** at a commit-pinned snapshot; `records/` and `broad-evidence.md` are not on PodlESP `main`.

## Privacy

- Committed docs are **sanitized reports**, not raw session transcripts.
- Raw Pi JSONL slices live only under `.private/` (ignored by git).
- Redact secrets and private external home paths before commit.
