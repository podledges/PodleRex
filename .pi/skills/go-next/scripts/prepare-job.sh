#!/usr/bin/env bash
# Package a captured snapshot into a durable go-next worker job.
# Emits fm-brief / fm-spawn commands for the podlesp secondmate (does not spawn
# by itself unless --spawn is passed and FM_HOME points at podlesp).
#
# Usage:
#   prepare-job.sh --snapshot DIR [--project-root DIR] [--task-id ID] [--spawn]
set -euo pipefail

SNAPSHOT=
PROJECT_ROOT=
TASK_ID=
DO_SPAWN=0
MODEL=${GO_NEXT_MODEL:-xai/grok-4.5}
EFFORT=${GO_NEXT_EFFORT:-high}
MODE=${GO_NEXT_MODE:-local-only}

while [ $# -gt 0 ]; do
  case "$1" in
    --snapshot) SNAPSHOT=$2; shift 2 ;;
    --project-root) PROJECT_ROOT=$2; shift 2 ;;
    --task-id) TASK_ID=$2; shift 2 ;;
    --spawn) DO_SPAWN=1; shift ;;
    --model) MODEL=$2; shift 2 ;;
    --effort) EFFORT=$2; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "error: unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$SNAPSHOT" ] || [ ! -d "$SNAPSHOT" ]; then
  echo "error: --snapshot DIR required" >&2
  exit 1
fi
SNAPSHOT=$(CDPATH='' cd -- "$SNAPSHOT" && pwd -P)
if [ ! -f "$SNAPSHOT/metadata.json" ]; then
  echo "error: snapshot missing metadata.json" >&2
  exit 1
fi

if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)
fi
PROJECT_ROOT=$(CDPATH='' cd -- "$PROJECT_ROOT" && pwd -P)

CAPTURE_ID=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["capture_id"])' "$SNAPSHOT/metadata.json")
SHORT=$(printf '%s' "$CAPTURE_ID" | tr -c 'a-zA-Z0-9' '-' | sed 's/--*/-/g' | cut -c1-40 | sed 's/-$//')
TASK_ID=${TASK_ID:-go-next-$SHORT}

JOB_DIR="$PROJECT_ROOT/ai-docs/.private/jobs/$TASK_ID"
if [ -e "$JOB_DIR" ]; then
  echo "error: job already exists (no overwrite): $JOB_DIR" >&2
  exit 1
fi
mkdir -p "$JOB_DIR"

# Pointer only — worker reads the immutable snapshot; no parent chat required.
ln -s "$SNAPSHOT" "$JOB_DIR/snapshot" 2>/dev/null || cp -a "$SNAPSHOT" "$JOB_DIR/snapshot"

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd -P)
cp "$SCRIPT_DIR/../references/worker-prompt.md" "$JOB_DIR/worker-prompt.md"
cp "$SCRIPT_DIR/../references/report-outline.md" "$JOB_DIR/report-outline.md"

python3 - "$JOB_DIR/job.json" <<PY
import json, os, time
job = {
  "schema": "podlerex-go-next-job/v1",
  "task_id": "$TASK_ID",
  "capture_id": "$CAPTURE_ID",
  "snapshot_dir": "snapshot",
  "project_root_hint": "PodleRex worktree containing ai-docs/",
  "model": "$MODEL",
  "effort": "$EFFORT",
  "mode": "$MODE",
  "created_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
  "worker_must_not": [
    "depend on parent chat memory or lifetime",
    "harvest unrelated project sessions",
    "publish raw transcripts by default",
    "overwrite existing ai-docs session reports",
    "perform hardware or firmware operations",
  ],
  "outputs": {
    "sanitized_report_glob": "ai-docs/sessions/*.md",
    "index": "ai-docs/index.md",
    "private_snapshot": "ai-docs/.private/snapshots/ (gitignored)",
  },
}
json.dump(job, open("$JOB_DIR/job.json", "w", encoding="utf-8"), indent=2, sort_keys=True)
PY

# Durable backlog note inside the job (secondmate also tracks via fm-brief).
cat > "$JOB_DIR/BACKLOG.md" <<EOF
# go-next job \`$TASK_ID\`

- Status: queued
- Capture: \`$CAPTURE_ID\`
- Snapshot: \`snapshot/\` (immutable)
- Model: \`$MODEL\` effort \`$EFFORT\`
- Delivery mode hint: \`$MODE\`

Worker reads only this job directory + linked snapshot + the PodleRex tree for writing \`ai-docs/\`.
EOF

SPAWN_CMDS="$JOB_DIR/SPAWN_COMMANDS.sh"
cat > "$SPAWN_CMDS" <<EOF
#!/usr/bin/env bash
# Run from the podlesp secondmate home (FM_HOME = podlesp).
# Durable tracking: fm-brief then fm-spawn — not an untracked child agent.
set -euo pipefail
FM_HOME=\${FM_HOME:?set FM_HOME to podlesp secondmate home}
FM_BIN=\${FM_BIN:-\$FM_HOME/bin}
TASK_ID='$TASK_ID'
PROJECT=\${PROJECT:-\$FM_HOME/projects/PodleRex}
JOB_DIR='$JOB_DIR'

# If the job lives in a worktree, prefer that tree as the spawn project dir when it is a PodleRex checkout.
if [ -d "\$PROJECT" ]; then
  :
else
  echo "error: PodleRex project clone not found at \$PROJECT" >&2
  exit 1
fi

"\$FM_BIN/fm-brief.sh" "\$TASK_ID" PodleRex --mode $MODE
# Replace brief {TASK} body is firstmate-owned; when invoking manually, append worker prompt:
{
  echo
  echo "# Task (go-next worker)"
  echo "Read and follow: \$JOB_DIR/worker-prompt.md"
  echo "Job dir: \$JOB_DIR"
  echo "Use only the snapshot under \$JOB_DIR/snapshot — do not rely on parent chat."
  echo "Write sanitized narrative under the PodleRex worktree ai-docs/ per report-outline.md."
  echo "Model requirement: $MODEL with effort $EFFORT."
} >> "\$FM_HOME/data/\$TASK_ID/brief.md"

"\$FM_BIN/fm-spawn.sh" "\$TASK_ID" "\$PROJECT" --mode $MODE --yolo off \\
  --harness pi --model $MODEL --effort $EFFORT
EOF
chmod +x "$SPAWN_CMDS"

if [ "$DO_SPAWN" -eq 1 ]; then
  if [ -z "${FM_HOME:-}" ] || [ ! -x "${FM_HOME}/bin/fm-brief.sh" ]; then
    echo "error: --spawn requires FM_HOME with fm-brief.sh" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  bash "$SPAWN_CMDS"
fi

printf '%s\n' "$JOB_DIR"
