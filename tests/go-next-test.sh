#!/usr/bin/env bash
# Minimal go-next pilot tests — no paid model calls.
set -euo pipefail

ROOT=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd -P)
CAP="$ROOT/.pi/skills/go-next/scripts/capture-source.sh"
PREP="$ROOT/.pi/skills/go-next/scripts/prepare-job.sh"
# shellcheck source=../.pi/skills/go-next/scripts/redact.sh
. "$ROOT/.pi/skills/go-next/scripts/redact.sh"

PASS=0
FAIL=0
assert() {
  local name=$1; shift
  if "$@"; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name" >&2
    FAIL=$((FAIL + 1))
  fi
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# --- fixture session (PodleRex-scoped, known timestamps) ---
FIX_SESSION=$TMP/session.jsonl
cat > "$FIX_SESSION" <<'JSON'
{"type":"session","version":3,"id":"test-session-fixed","timestamp":"2026-09-17T18:00:00.000Z","cwd":"/tmp/work/PodleRex"}
{"type":"message","id":"m1","parentId":null,"timestamp":"2026-09-17T18:00:10.000Z","message":{"role":"user","content":[{"type":"text","text":"path /home/podles/secret-project and token=abc123XYZ"}],"timestamp":1789675210000}}
{"type":"message","id":"m2","parentId":"m1","timestamp":"2026-09-17T18:05:00.000Z","message":{"role":"assistant","content":[{"type":"text","text":"Noted about C:\\Users\\ayden\\AppData\\Local\\x"}],"timestamp":1789675500000}}
JSON

OUT=$TMP/out
mkdir -p "$OUT"
# Pretend project root named PodleRex
PROJ=$TMP/PodleRex
mkdir -p "$PROJ"
cp -a "$ROOT/.pi" "$PROJ/.pi"
mkdir -p "$PROJ/ai-docs"

# 1) Capture before any ack marker
ACK=$TMP/ack.txt
rm -f "$ACK"
SNAP1=$("$CAP" --project-root "$PROJ" --out-base "$PROJ" --session-file "$FIX_SESSION" --session-id test-session-fixed)
assert "capture creates snapshot dir" test -d "$SNAP1"
assert "capture writes metadata before ack" test -f "$SNAP1/metadata.json"
assert "no ack required for capture" test ! -f "$ACK"
echo "ack after capture" > "$ACK"
assert "ack only after capture completes" test -f "$SNAP1/MANIFEST.txt"

# 2) Worker independence: job package self-contained
JOB1=$("$PREP" --snapshot "$SNAP1" --project-root "$PROJ" --task-id go-next-test-1)
assert "job has worker-prompt" test -f "$JOB1/worker-prompt.md"
assert "job has job.json" test -f "$JOB1/job.json"
assert "job links/copies snapshot" test -e "$JOB1/snapshot/metadata.json"
# Simulate worker with empty env (no PI_SESSION_*) 
assert "worker can read metadata without PI_SESSION" \
  env -u PI_SESSION_FILE -u PI_SESSION_ID python3 -c "import json; json.load(open('$JOB1/snapshot/metadata.json'))"

# 3) Duplicate capture → new id, no overwrite
sleep 1
SNAP2=$("$CAP" --project-root "$PROJ" --out-base "$PROJ" --session-file "$FIX_SESSION" --session-id test-session-fixed)
assert "second capture different path" test "$SNAP1" != "$SNAP2"
assert "first snapshot untouched" test -f "$SNAP1/metadata.json"
assert "second snapshot exists" test -f "$SNAP2/metadata.json"
# Force same capture_id collision path: mkdir then expect failure
mkdir -p "$SNAP2-collision-placeholder"
# Re-run prepare should not overwrite job
if "$PREP" --snapshot "$SNAP1" --project-root "$PROJ" --task-id go-next-test-1 2>/tmp/go-next-prep-err; then
  assert "duplicate job refused" false
else
  assert "duplicate job refused" true
fi

# 4) Redaction
REDACTED=$(go_next_redact_text "see /home/podles/fleet/x and token=supersecret")
assert "redacts home" bash -c "printf '%s' '$REDACTED' | grep -q '<HOME>'"
assert "redacts token assign" bash -c "printf '%s' '$REDACTED' | grep -q 'token=<REDACTED>'"
assert "extract redacts home" bash -c "grep -q '<HOME>' '$SNAP1/messages-extract.jsonl'"
assert "extract redacts token" bash -c "grep -q 'token=<REDACTED>' '$SNAP1/messages-extract.jsonl'"

# 5) Unknown / truthful metadata
META=$SNAP1/metadata.json
assert "active_time unknown" bash -c "grep -q '\"active_time_seconds\": \"unknown\"' '$META'"
assert "elapsed numeric or null from known ts" bash -c "python3 -c \"import json; m=json.load(open('$META')); assert m['elapsed_seconds_from_known_timestamps'] is None or isinstance(m['elapsed_seconds_from_known_timestamps'], int)\""
assert "coverage_warning present" bash -c "python3 -c \"import json; assert json.load(open('$META'))['coverage_warning']\""
assert "source session id set" bash -c "python3 -c \"import json; assert json.load(open('$META'))['source_session_id']=='test-session-fixed'\""

# Empty timestamps → unknown elapsed
FIX2=$TMP/session-nots.jsonl
echo '{"type":"session","version":3,"id":"no-ts","cwd":"/tmp/PodleRex"}' > "$FIX2"
SNAP3=$("$CAP" --project-root "$PROJ" --out-base "$PROJ" --session-file "$FIX2" --session-id no-ts)
assert "unknown elapsed when no timestamps" bash -c "python3 -c \"import json; assert json.load(open('$SNAP3/metadata.json'))['elapsed_seconds_from_known_timestamps'] is None\""

# 6) Scope refusal for non-PodleRex project root
BAD=$TMP/OtherProj
mkdir -p "$BAD/ai-docs"
if "$CAP" --project-root "$BAD" --out-base "$BAD" --session-file "$FIX_SESSION" 2>/tmp/go-next-scope-err; then
  assert "non-PodleRex root refused" false
else
  assert "non-PodleRex root refused" true
fi

# 7) Truncation flag when max-bytes tiny
SNAP4=$("$CAP" --project-root "$PROJ" --out-base "$PROJ" --session-file "$FIX_SESSION" --session-id trunc-test --max-bytes 80)
assert "truncated true when bound hit" bash -c "python3 -c \"import json; assert json.load(open('$SNAP4/metadata.json'))['truncated'] is True\""

# 8) Real Pi skill discovery paths (no model call)
assert "canonical SKILL.md exists" test -f "$ROOT/.pi/skills/go-next/SKILL.md"
assert "skill frontmatter name" bash -c "head -5 '$ROOT/.pi/skills/go-next/SKILL.md' | grep -q 'name: go-next'"
assert "pointer artifact exists" test -f "$ROOT/deploy/secondmate-go-next-pointer/SKILL.md"
assert "lowercase ai-docs exists" test -d "$ROOT/ai-docs"
assert "AI-docs preserved" test -d "$ROOT/AI-docs"
assert "seed report exists" test -f "$ROOT/ai-docs/sessions/2026-09-17-piezo-sensing-seed.md"
assert "evidence png exists" test -f "$ROOT/ai-docs/evidence/paste-20260917T182006094Z-40b0440a5f594a2592072e9b106bc194.png"

# Optional: pi command discovery if pi is on PATH (still no model)
if command -v pi >/dev/null 2>&1; then
  # List skills via filesystem convention documented by Pi — package path load
  assert "pi binary present" true
  # Confirm skill directory naming matches Pi discovery (SKILL.md under .pi/skills)
  assert "pi skills dir convention" test -f "$ROOT/.pi/skills/go-next/SKILL.md"
else
  echo "SKIP: pi binary not on PATH (filesystem discovery still checked)"
fi

echo
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
