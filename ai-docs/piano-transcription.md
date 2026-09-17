---
title: "Piano audio transcription: PodleRex companion"
report_date: "2026-09-17"
status: "Source-only research companion; canonical vault pending merge"
---

# Piano audio transcription: implications for PodleRex

[Index](README.md)

The canonical four-report research vault lives in **PodlESP/ai-docs/piano-transcription**.
It is proposed in [PodlESP PR #13](https://github.com/podledges/PodlESP/pull/13)
at commit [`d22feb617b53fa18901f3101269ee74b9ccd93bc`](https://github.com/podledges/PodlESP/tree/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription),
stacked on still-open [PR #12](https://github.com/podledges/PodlESP/pull/12).
**Neither PR is merged; the vault is not on PodlESP `main` yet.** Links below are
pinned to that reviewed snapshot, not to temporary local paths or unmerged `main`.

Canonical pages (commit-pinned):

- [overview](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/README.md)
- [broad evidence](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/broad-evidence.md)
- [source register](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/sources.md)
- [piezo and ADC notes](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/piezo-and-adc.md)
- [future evaluation protocol](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/experiments.md)

Sanitized source records from all four scouts (2026-09-17) — link, do not copy:

- [earlier-astra](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/records/earlier-astra.md)
- [earlier-grok](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/records/earlier-grok.md)
- [broad-astra](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/records/broad-astra.md)
- [broad-grok](https://github.com/podledges/PodlESP/blob/d22feb617b53fa18901f3101269ee74b9ccd93bc/ai-docs/piano-transcription/records/broad-grok.md)

## What is established?

- **MCU multipitch exists:** Cortex-M7 two-note violin and RP2040 triad-label demos.
  Neither establishes general polyphonic acoustic-piano pitch/onset transcription.
- **ESP32-S3 isolated-note ML exists:** Huang reports 99.6% on 1000 live notes;
  217.8 ms processing follows 512 ms collection, not measured total response.
- **General polyphonic piano on MCU remains unverified**, not impossible.
  PC/mobile/template baselines exist, but their timing/memory cannot be assigned
  to MCU hardware. Patent disclosure does not establish a shipped product.

Separate concerns: monophonic or isolated-note classification, limited multipitch
demos, and full polyphonic acoustic-piano transcription (onsets, offsets, velocity,
pedal) are different problems. Do not collapse them when reading MCU claims.

## Relevance to a future PodleRex integration

PodleRex explores piezo sensing and parallel analog frontends into an ESP32-S3 ADC.
Treat audio-inferred notes, chord labels and key-sensor MIDI as different inputs.
For any event-driven consumer, retain **when the event became available**, not
just its backdated musical onset. Report pitch/onset, offset, velocity and pedal
separately; missing expressivity must not erase a real onset result.

M7's 0.98 ms task follows 64 ms blocks and beat aggregation. Pianolizer's live
analysis is distinct from its whole-file MIDI exporter. Mobile-AMT's 174 ms
formula and later pooling critique remain unresolved as measured end-to-end
claims. These distinctions matter before assuming responsive downstream behavior.

Held-out pianos, adversarial chords/restrikes, matched air/contact signals,
causality checks and common-clock stimulus-to-output timing belong in evaluation
before product claims. Piezo input still contains a mixture; **electrical
sign-off and fresh authorization precede any hardware work.** This note is not
circuit or firmware authority.

This companion proposes no integration, firmware, hardware or purchases. It links
to one canonical evidence vault rather than maintaining a competing copy.
