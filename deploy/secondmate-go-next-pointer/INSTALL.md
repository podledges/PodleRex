# Install go-next pointer into podlesp secondmate home

**Canonical skill stays in the PodleRex repo** at `.pi/skills/go-next/`.  
This directory is only the secondmate-local discovery pointer.

## Exact supervisor step

Do **not** have a crewmate write outside its worktree. From the supervisor (or a human) on the podlesp secondmate home:

```bash
FM_HOME=/home/podles/fleet/podlesp   # or the live secondmate FM_HOME
REPO="$FM_HOME/projects/PodleRex"    # after merge, or a worktree path that contains deploy/

mkdir -p "$FM_HOME/.agents/skills"
rm -rf "$FM_HOME/.agents/skills/go-next"
cp -a "$REPO/deploy/secondmate-go-next-pointer" "$FM_HOME/.agents/skills/go-next"
```

Symlink alternative (updates with the repo):

```bash
ln -sfn "$REPO/deploy/secondmate-go-next-pointer" "$FM_HOME/.agents/skills/go-next"
```

Verify Pi/agent skill discovery lists `go-next` from the secondmate home, then open a PodleRex session and run `/skill:go-next`.

## Uninstall

```bash
rm -rf "$FM_HOME/.agents/skills/go-next"
```
