---
name: go-next
description: >-
  Pointer skill for the podlesp secondmate. Loads PodleRex project go-next:
  session-boundary capture into ai-docs via fm-brief/fm-spawn. Use on /go-next
  when the active project is PodleRex or the captain wants this chat retained
  as project documentation.
---

# go-next (secondmate pointer)

This file is a **private secondmate-home pointer**, not the canonical skill body.

1. Resolve PodleRex checkout (prefer `$FM_HOME/projects/PodleRex`, else the active worktree whose root is PodleRex).
2. **Read and follow** that tree's canonical skill:
   ```text
   <PodleRex>/.pi/skills/go-next/SKILL.md
   ```
3. Run its pipeline there: **capture → prepare-job → fm-brief/fm-spawn** (see that skill). Do not invent a second pipeline here.
4. Scope stays PodleRex-only. No hardware operations.

Install: see `INSTALL.md` beside this file.
