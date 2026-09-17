#!/usr/bin/env bash
# Capture an immutable, bounded Pi session source snapshot for go-next.
# Must complete BEFORE any reset-safe acknowledgement.
#
# Usage:
#   capture-source.sh [--project-root DIR] [--session-file PATH] [--session-id ID]
#                     [--cwd-hint PATH] [--out-base DIR] [--max-bytes N]
#
# Writes under <out-base>/ai-docs/.private/snapshots/<capture_id>/:
#   source.jsonl
#   metadata.json
#   messages-extract.jsonl
#   MANIFEST.txt
#
# Prints snapshot directory path on stdout. Never overwrites an existing capture.
set -euo pipefail

PROJECT_ROOT=
SESSION_FILE=${PI_SESSION_FILE:-}
SESSION_ID=${PI_SESSION_ID:-}
CWD_HINT=
OUT_BASE=
MAX_BYTES=2097152

while [ $# -gt 0 ]; do
  case "$1" in
    --project-root) PROJECT_ROOT=$2; shift 2 ;;
    --session-file) SESSION_FILE=$2; shift 2 ;;
    --session-id) SESSION_ID=$2; shift 2 ;;
    --cwd-hint) CWD_HINT=$2; shift 2 ;;
    --out-base) OUT_BASE=$2; shift 2 ;;
    --max-bytes) MAX_BYTES=$2; shift 2 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)
fi
PROJECT_ROOT=$(CDPATH='' cd -- "$PROJECT_ROOT" && pwd -P)
OUT_BASE=${OUT_BASE:-$PROJECT_ROOT}
OUT_BASE=$(CDPATH='' cd -- "$OUT_BASE" && pwd -P)

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd -P)
# shellcheck source=redact.sh
. "$SCRIPT_DIR/redact.sh"

if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  echo "error: session file missing or unreadable (set --session-file or PI_SESSION_FILE)" >&2
  exit 1
fi
SESSION_FILE=$(CDPATH='' cd -- "$(dirname "$SESSION_FILE")" && pwd -P)/$(basename "$SESSION_FILE")

if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(head -n 1 "$SESSION_FILE" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1 || true)
  if [ -z "$SESSION_ID" ]; then
    SESSION_ID=$(basename "$SESSION_FILE" .jsonl)
  fi
fi

case "$PROJECT_ROOT" in
  *[Pp]odle[Rr]ex*) : ;;
  *) echo "error: project root is not PodleRex-scoped: $PROJECT_ROOT" >&2; exit 1 ;;
esac

SCOPE_OK=0
HEADER_CWD=$(head -n 1 "$SESSION_FILE" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1 || true)
case "$SESSION_FILE${HEADER_CWD:-}${CWD_HINT:-}$PROJECT_ROOT" in
  *[Pp]odle[Rr]ex*) SCOPE_OK=1 ;;
esac
if [ "$SCOPE_OK" -ne 1 ]; then
  echo "error: session is not PodleRex-scoped (refusing cross-project harvest)" >&2
  exit 1
fi

CAPTURE_CUTOFF=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CUTOFF_EPOCH=$(date -u +%s)
FINGERPRINT=$(sha256sum "$SESSION_FILE" | awk '{print substr($1,1,12)}')
CAPTURE_ID="${SESSION_ID}-${CUTOFF_EPOCH}-${FINGERPRINT}"

SNAP_DIR="$OUT_BASE/ai-docs/.private/snapshots/$CAPTURE_ID"
if [ -e "$SNAP_DIR" ]; then
  echo "error: capture already exists (no overwrite): $SNAP_DIR" >&2
  exit 1
fi
mkdir -p "$SNAP_DIR"

SRC_SIZE=$(wc -c < "$SESSION_FILE" | tr -d ' ')
TRUNCATED=0
if [ "$SRC_SIZE" -gt "$MAX_BYTES" ]; then
  head -c "$MAX_BYTES" "$SESSION_FILE" > "$SNAP_DIR/source.jsonl"
  TRUNCATED=1
  COPIED=$MAX_BYTES
else
  cp -p "$SESSION_FILE" "$SNAP_DIR/source.jsonl"
  COPIED=$SRC_SIZE
fi

# Timestamp scan + message extract + metadata in one python pass.
REPORT_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TZ_NAME=$(date +%Z)
TZ_OFFSET=$(date +%z)
export SNAP_DIR SESSION_ID SESSION_FILE PROJECT_ROOT HEADER_CWD
export CAPTURE_ID CAPTURE_CUTOFF REPORT_TS
SESSION_BASENAME=$(basename "$SESSION_FILE")
SRC_REDACTED=$(go_next_redact_text "$SESSION_FILE")
ROOT_REDACTED=$(go_next_redact_text "$PROJECT_ROOT")
CWD_REDACTED=$(go_next_redact_text "${HEADER_CWD:-unknown}")

python3 - <<PY
import json, os, re
from datetime import datetime, timezone

snap = os.environ["SNAP_DIR"]
src_path = os.path.join(snap, "source.jsonl")
patterns = [
    (re.compile(r"/home/[^/\s\"']+"), "<HOME>"),
    (re.compile(r"/mnt/c/Users/[^/\s\"']+"), "<WIN_USER>"),
    (re.compile(r"C:\\\\Users\\\\[^\\s\"']+"), "<WIN_USER>"),
    (re.compile(r"C:/Users/[^/\s\"']+"), "<WIN_USER>"),
    (re.compile(r"(?i)(api[_-]?key|token|secret|password)\s*[:=]\s*\S+"), r"\1=<REDACTED>"),
    (re.compile(r"ssh-ed25519\s+\S+"), "ssh-ed25519 <REDACTED>"),
]
def redact(s: str) -> str:
    for rx, rep in patterns:
        s = rx.sub(rep, s)
    return s

def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            (b.get("text") or "") for b in content
            if isinstance(b, dict) and b.get("type") == "text"
        )
    return ""

vals = []
iso_re = re.compile(r"^\d{4}-\d{2}-\d{2}T")
extract = open(os.path.join(snap, "messages-extract.jsonl"), "w", encoding="utf-8")
with open(src_path, "r", encoding="utf-8", errors="replace") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        t = obj.get("timestamp")
        msg = obj.get("message") if isinstance(obj.get("message"), dict) else None
        if t is None and msg:
            t = msg.get("timestamp")
        if isinstance(t, (int, float)):
            t = float(t)
            if t > 10_000_000_000:
                t /= 1000.0
            vals.append(t)
        elif isinstance(t, str) and iso_re.match(t):
            s = t.replace("Z", "+00:00")
            try:
                vals.append(datetime.fromisoformat(s).timestamp())
            except Exception:
                pass
        if obj.get("type") == "message" and msg:
            role = msg.get("role")
            if role in ("user", "assistant"):
                text = text_of(msg.get("content"))
                if text.strip():
                    extract.write(json.dumps({
                        "id": obj.get("id"),
                        "role": role,
                        "timestamp": obj.get("timestamp") or msg.get("timestamp"),
                        "text": redact(text),
                    }, ensure_ascii=False) + "\n")
extract.close()

def fmt(ts):
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

if vals:
    lo, hi = min(vals), max(vals)
    obs_start, obs_end = fmt(lo), fmt(hi)
    elapsed = int(hi - lo)
else:
    obs_start = obs_end = "unknown"
    elapsed = None

truncated = ${TRUNCATED}
src_size = ${SRC_SIZE}
copied = ${COPIED}
max_bytes = ${MAX_BYTES}
if truncated:
    coverage = "Capture truncated at max-bytes bound; not a full session archive."
elif obs_start == "unknown":
    coverage = "Timestamps incomplete; elapsed duration unknown."
else:
    coverage = "Bounded single-session capture only; completeness and retention of upstream history are unknown."

meta = {
    "schema": "podlerex-go-next-capture/v1",
    "capture_id": os.environ["CAPTURE_ID"],
    "report_timestamp_utc": os.environ.get("REPORT_TS") or "${REPORT_TS}",
    "report_timezone_name": "${TZ_NAME}",
    "report_timezone_offset": "${TZ_OFFSET}",
    "source_session_id": os.environ["SESSION_ID"],
    "source_session_file_basename": "${SESSION_BASENAME}",
    "source_session_file_private_redacted": """${SRC_REDACTED}""",
    "observed_start_utc": obs_start,
    "observed_end_utc": obs_end,
    "capture_cutoff_utc": os.environ["CAPTURE_CUTOFF"],
    "elapsed_seconds_from_known_timestamps": elapsed,
    "elapsed_note": "Wall-clock span between earliest and latest known timestamps in the captured slice only. Not active model/tool time.",
    "active_time_seconds": "unknown",
    "active_time_note": "Pi session JSONL does not record reliable active working time; do not invent it.",
    "bytes_in_source_file": src_size,
    "bytes_copied": copied,
    "truncated": bool(truncated),
    "max_bytes_bound": max_bytes,
    "coverage_warning": coverage,
    "scope": "PodleRex-only",
    "project_root_redacted": """${ROOT_REDACTED}""",
    "header_cwd_redacted": """${CWD_REDACTED}""",
    "worker_independence": "All inputs for documentation are under this snapshot directory; worker must not read parent chat memory.",
}
with open(os.path.join(snap, "metadata.json"), "w", encoding="utf-8") as mf:
    json.dump(meta, mf, indent=2, sort_keys=True)
    mf.write("\n")
PY

{
  echo "capture_id=$CAPTURE_ID"
  echo "snapshot_dir=$SNAP_DIR"
  echo "source_session_id=$SESSION_ID"
  echo "capture_cutoff_utc=$CAPTURE_CUTOFF"
  echo "truncated=$TRUNCATED"
  echo "files:"
  ls -1 "$SNAP_DIR" | sed 's/^/  /'
} > "$SNAP_DIR/MANIFEST.txt"

printf '%s\n' "$SNAP_DIR"
