# house

Your team's own boards, served and checked beside the public ones.

This repo is public, so anything you `git add` here can end up pushed to it. Keep house boards in a
folder outside the checkout, and point `HOUSE_DIR` at it:

```bash
make serve HOUSE_DIR=~/work/house-boards
```

If you do keep them here, git ignores everything in this folder except this README and `_template/`.
`make verify` fails if any other file under `house/` is tracked. `make setup` installs the same check
as a pre-commit hook.

## Adding a board

1. Copy `_template/project.yaml.example` to `project.yaml` at the top of your house folder.
2. Copy `_template/board/` beside it, named for your board, and put the board's files in it.
3. Rename its `design.yaml.example` to `design.yaml` and set `entry` and `companions`.
4. Check it reads: `make verify AGNI=agni` reads every house board, and `make check
   DESIGN=mount://house/<board>` runs the rules on one.

Every target in the top-level README takes `DESIGN=mount://house/<board>`. Reports go to `reports/`,
and git ignores that folder too. The reports carry every net name and reference designator, so they
stay on your machine. Only the `make intake` and `make trial` reports are meant to leave it.
