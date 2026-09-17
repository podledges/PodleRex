#!/usr/bin/env bash
# Redaction helpers for PodleRex go-next private→public boundary.
# shellcheck shell=bash

go_next_redact_text() {
  # stdin or $1 → stdout
  local s
  if [ $# -ge 1 ]; then
    s=$1
  else
    s=$(cat)
  fi
  # Home and Windows user roots → placeholders (keep relative project meaning).
  s=$(printf '%s' "$s" | sed -E \
    -e 's|/home/[^/[:space:]"'\'']+|<HOME>|g' \
    -e 's|/mnt/c/Users/[^/[:space:]"'\'']+|<WIN_USER>|g' \
    -e 's|C:\\Users\\[^\\[:space:]"'\'']+|<WIN_USER>|g' \
    -e 's|C:/Users/[^/[:space:]"'\'']+|<WIN_USER>|g')
  # Credential-ish assignments.
  s=$(printf '%s' "$s" | sed -E \
    -e 's/(api[_-]?key|token|secret|password)[[:space:]]*[:=][[:space:]]*[^[:space:]]+/\1=<REDACTED>/Ig')
  # SSH public key material blobs.
  s=$(printf '%s' "$s" | sed -E 's/ssh-ed25519[[:space:]]+[^[:space:]]+/ssh-ed25519 <REDACTED>/g')
  printf '%s' "$s"
}

go_next_redact_file() {
  local in=$1 out=$2
  go_next_redact_text < "$in" > "$out"
}
