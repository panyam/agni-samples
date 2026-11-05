# agni-samples

Real, publicly-licensed electronic designs that [agni](https://github.com/panyam/agni) reads in its
tests, its tutorial, and its reader cross-checks.

None of these boards are ours.  Each was published by someone else under an open licence and sits in
`boards/<name>/` with the upstream `LICENSE` and `README.md` it came with.  `PROVENANCE.md` records
where each came from and what, if anything, was changed.

They live in their own repo so that the engine repo stays a single licence and these keep theirs.

## The boards

| board | components | sheets | licence |
|---|---:|---:|---|
| `jetson-agx-thor-baseboard` | 1123 | 17 | Apache-2.0 |
| `royalblue54L-feather` | 71 | 1 | CERN-OHL-P |
| `hackrf-one` | 418 | 4 | CERN-OHL-P |
| `glasgow-revC3` | 257 | 3 | 0BSD |
| `cynthion` | 348 | 17 | CERN-OHL-P |
| `mnt-reform-motherboard30` | 529 | 13 | CERN-OHL-S |

ODB++ jobs sit apart, under `odb/` (see `PROVENANCE.md`): foxBMS's five boards as Altium Designer
wrote them (CC-BY-4.0), three boards as Allegro's tools wrote them (CERN-OHL-S, CC-BY-4.0, OCP
permissive), and each KiCad board above as kicad-cli exports it.

Cadence's other exports sit under `cadence/`, each with a `design.yaml`: the Parallella parasdr as
Allegro wrote it to IPC-2581 (CC BY-SA 3.0 US), and Clay R6 as OrCAD Capture wrote it to EDIF (MIT).

Allegro boards sit under `allegro/`, each as BeagleBoard.org published it (CC-BY-4.0).  The
BeagleBone AI comes with an extract Allegro wrote from it.  BeaglePlay, BeagleV-Fire and BeagleBone
AI-64 come with the other files Allegro wrote beside each board: Gerbers and drill files, or a
placement report.  Their `.brd` files span the three header families BeagleBoard's boards use.

## Opening them in agni

A checkout is something `agni serve` can open as it stands.  `agni.yaml` at the root mounts `boards/`,
`odb/`, `cadence/` and `house/`, so `agni check mount://boards/hackrf-one` works at the root with no
flags.  Run it from the root: agni finds `agni.yaml` from a subfolder too, but reads its paths
against the folder you're in.
You need agni v0.4.0 or later, the first release with the ODB++ reader.

```bash
make serve        # the viewer over every board, job and house board, at http://127.0.0.1:8080/
make serve-wasm   # the same, with each design analysed in your browser
make site         # the whole set as static files in site/, the way agni's public demo is built
```

`AGNI` names the binary and defaults to the `agni` on your PATH.  A release binary carries the
viewer.  A dev build (`make agni` in an agni checkout) carries none, so name its `web/` too:
`make serve AGNI=../agni/bin/agni WEB_DIR=../agni/web`.  `make site` and `make serve-wasm` need the
wasm engine built there as well (`make ui wasm`).  `PORT` moves the server, and `MCP=1` also serves
agni's analysis to an agent at `/mcp`.

In `serve-wasm` a design bigger than serve's `--wasm-max-bytes` (128 MB) goes to the server engine,
and the page says so.  Jetson is about 92 MB, so every board here runs in the browser.

`make verify` checks that each board folder has a `design.yaml` and a `PROVENANCE.md` section, and
that no `project.yaml` sits over the boards.  `make verify AGNI=agni` also reads every board, job
and house board, and fails on one that reads as no components.  `make test` checks those checks.  CI runs both.

## Your own boards beside these

A team can clone this repo and run every analysis on its own boards, after seeing each one work on a
public board first.  `make tour` runs every target below on Glasgow.

Your boards go in a third mount, `house`.  It defaults to `house/` in the checkout, and
`HOUSE_DIR=<folder>` moves it.  A folder outside the checkout is safer, since this repo is public.
`house/README.md` walks through adding a board from the template, with a `project.yaml` for your
team's conventions, checklists and query sets.  `make setup` installs a pre-commit hook that refuses
a commit with a house board in it.

Each target runs one agni command over `DESIGN=mount://...`, which defaults to Glasgow:

| target | runs |
|---|---|
| `make check` | every rule, as text, and the verdict report in `reports/<name>-check.html` |
| `make review CHECKLIST=...` | a checklist walk, and its report in `reports/`.  Defaults to `examples/checklist.yaml` |
| `make diff A=... B=...` | the structural diff of two revisions or two views.  `RENAME_APPROX=1` pairs renamed nets that also changed |
| `make query SET=...` | a query set.  Defaults to `examples/queries.yaml` |
| `make trace FROM=U1.51 TO=U14.3` | the series path between two pins |
| `make lexicon` | the vocabulary agni reads the design's names with |
| `make pinmap` | a row per pin the design's `io_map` declares, in `reports/<name>-pins.csv` |
| `make intake` | the sanitized summary, with no net name in it |
| `make trial` | the `agni trial` report, with no name from the design in it |

`reports/` is gitignored.  Everything in it except the intake and trial reports carries your net names
and reference designators.  These variables come from the make command line only, so a `DESIGN`
exported for another project's Makefile doesn't reach these targets.

## Using these from the engine

The engine fetches a **pinned release tarball**, verified by checksum, into a gitignored directory.
It does not use a git submodule, so an engine clone does not carry this repo.

Tarballs are built per purpose, so a job downloads only what it needs:

| tarball | contents |
|---|---|
| `tutorial-board` | the Jetson baseboard, schematics only |
| `oracle-corpus` | every board, schematics and board files |
| `odb-altium` | ODB++ jobs Altium Designer wrote (the foxBMS boards), byte-identical to their publisher's |
| `odb-kicad` | each board above exported to ODB++ by kicad-cli, for reading a board both ways |
| `allegro` | the BeagleBone AI's Allegro `.brd`, with the extract Allegro wrote from the same board |
| `cadence-exports` | ODB++ jobs Allegro's tools wrote (`odb/allegro/`), and the IPC-2581 and EDIF exports under `cadence/` |
| `allegro-boards` | three more Allegro `.brd` boards, with the Gerbers, drill files, placement report and OrCAD schematics Allegro and OrCAD wrote beside them |

`make dist` builds them all and writes `SHA256SUMS`.  `make list` prints the lines to pin.  `make
verify-dist` checks a built set against its sums.

Released artifacts are the pinned ones.  Verify a download against the `SHA256SUMS` attached to the
release rather than against a local rebuild, since archive metadata varies between machines.

## Adding a board

1. **Check the licence, and stop if there is not one.**  A design shipped with no LICENSE file cannot
   be redistributed here whatever its origin.  Permissive and reciprocal open-hardware licences are
   fine (PROVENANCE.md, "Reciprocal licences").  NonCommercial terms are not.
2. Copy the design **verbatim**, including its `LICENSE` and `README.md`.  Some tests compare a read
   against the upstream tool's own output, so an edited file stops being usable as a reference.
3. Drop editor state and renders (`.kicad_prl`, `.lck`, `img/`).  Keep symbol and footprint libraries,
   since resolving them is under test.
4. Add a section to `PROVENANCE.md`: upstream, source, licence, date taken, and any modification.
5. Add a `design.yaml` naming its entry and companions (agni's `agni propose <folder>` drafts one).
   It is served on the next `make serve`.  Don't add a `project.yaml` above it: a design under a
   `project.yaml` that it does not `extends` fails to load.
6. Run `make verify AGNI=agni`.
7. Add it to a tarball target in the `Makefile` if a test needs it.

## Licence

Each design carries its own licence, board by board, and those govern the design files.  `LICENSE` at
the top level covers only the packaging in this repo: the makefile and the provenance records.
