# Podle Cyberpunk - visual style for PodleRex

This folder ships **only** the Podle Cyberpunk theme. Its canonical KiCad theme file is `podle-cyberpunk.json` (meta name **Podle Cyberpunk**, version 3). Prefer it for circuit screenshots and review stills.

## Mood
Near-black canvas, high-saturation neon accents, cyan/magenta/pink hierarchy. Dark-room cyberpunk, not pastel and not pure monochrome.

## Core palette (use these first)
| Role | RGB | Notes |
|------|-----|-------|
| Canvas / deep bg | `10, 10, 18` | Schematic + board background |
| Grid | `40, 40, 70` | Low-contrast structure only |
| Primary signal (wires / cyan neon) | `0, 255, 200` to `0, 255, 220` | Wires, shadow tint, top silks |
| Hot accent (bus / magenta) | `255, 0, 170` to `255, 80, 200` | Buses, global labels, front copper vibe |
| Component outline | `255, 0, 200` | Pink-magenta edges |
| Component body | `28, 12, 40` | Deep purple fill |
| Pins / cool info | `0, 220, 255` | Pin geometry |
| Pin names | `180, 255, 255` | Light cyan text |
| Junctions / attention yellow | `255, 230, 0` | Junction dots |
| Hierarchy / sheet purple | `100, 80, 255` to `160, 120, 255` | Sheets, hierarchical labels |
| Errors | `255, 40, 80` | ERC / no-connect red-pink |
| Warnings | `255, 200, 0` | ERC warning |
| Cursor | `255, 255, 100` | High-vis yellow |

## Schematic hierarchy (readability contract)
1. **Structure first:** dark bg + muted grid; never bright-fill the canvas.
2. **Connectivity second:** cyan wires vs magenta buses - keep that opposition when inventing new UI or diagram colors.
3. **Parts third:** purple body + hot pink outline; pins cool-cyan so they separate from outlines.
4. **Labels:** local = green-cyan; global = hot pink; hierarchical = violet - do not collapse these three roles into one color.
5. **Faults last and loudest:** red-pink errors, yellow warnings; never use error red for decoration.

## Board / PCB echo (same theme file)
- Front copper is hot pink `255, 80, 160`; back copper is teal `0, 220, 180`.
- Front silks cyan; back silks pink - mirrors schematic wire/bus split.
- Edge cuts warm amber `255, 184, 108`.
- Keep the same near-black field `10, 10, 18`.

## Rules for future non-KiCad design (docs, slides, product shots)
- Start from the **core palette** table; do not introduce a second neon system.
- Prefer **one** cool neon + **one** hot neon on near-black; extra hues only for strict hierarchy (labels, layers, severity).
- Avoid pure white fills; brightened/white is for selection highlight only.
- Avoid flat gray corporate themes and warm paper backgrounds for “official” PodleRex electronics visuals.
- Window chrome / OS dark mode is separate from this canvas theme - do not require a custom KiCad UI skin for screenshots to read as Podle Cyberpunk.

## Install (KiCad 10)
Copy `podle-cyberpunk.json` into the user colors dir, restart KiCad, then:
**Schematic Editor → Preferences → Schematic Editor → Colors → Theme → Podle Cyberpunk**

- Windows: `%APPDATA%\kicad\10.0\colors\`
- Linux: `~/.config/kicad/10.0/colors/`
