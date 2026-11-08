# agni-samples

Real, publicly-licensed electronic designs that [agni](https://github.com/panyam/agni) reads in its
tests, its tutorial, and its reader cross-checks.

None of these designs are ours.  Someone else published each one under an open licence.  Each
folder keeps the upstream `LICENSE` that came with the design, and the KiCad boards under `boards/`
keep their upstream `README.md` too.  `PROVENANCE.md` records where each design came from, and what
was changed, if anything.

They live in their own repo, so the engine repo keeps a single licence and these keep theirs.

## The boards

| board | components | sheets | licence |
|---|---:|---:|---|
| `jetson-agx-thor-baseboard` | 1123 | 17 | Apache-2.0 |
| `royalblue54L-feather` | 71 | 1 | CERN-OHL-P |
| `hackrf-one` | 418 | 4 | CERN-OHL-P |
| `glasgow-revC3` | 257 | 3 | 0BSD |
| `cynthion` | 348 | 17 | CERN-OHL-P |
| `mnt-reform-motherboard30` | 529 | 13 | CERN-OHL-S |

ODB++ jobs sit apart, under `odb/` (see `PROVENANCE.md`).  Altium Designer wrote foxBMS's five
boards (CC-BY-4.0).  Allegro's tools wrote three more boards (CERN-OHL-S, CC-BY-4.0, OCP permissive).
kicad-cli exported each KiCad board above.

`cadence/` holds Cadence's other exports, and each has a `design.yaml`.  Allegro wrote the Parallella
parasdr to IPC-2581 and ODB++X (CC BY-SA 3.0 US), and its Allegro 16.6 board sits beside them.
OrCAD Capture wrote Clay R6 to EDIF (MIT).  Clay R6's Allegro 16.6 board sits beside it with
`pstxnet.dat`, the netlist Capture handed Allegro for that board.

`allegro/` holds Allegro boards, each as its publisher released it.  Four come from BeagleBoard.org
(CC-BY-4.0).  The BeagleBone AI comes with an extract that Allegro wrote from it.  BeaglePlay,
BeagleV-Fire and BeagleBone AI-64 come with other files Allegro wrote beside each board, such as
Gerbers and drill files, or a placement report.  BeagleBoard's Allegro boards use three `.brd`
header families, and these four cover all three.  The other two `.brd` boards are pc069 and the
OpenCellular breakout.  Each publisher also released an ODB++ job of the same board, under
`odb/allegro/`.  SLUGS v2 (MIT, Allegro 16.0), Parallella-I (CC BY-SA 3.0 US, 16.4) and the
ADALM1000 (CC BY-SA 3.0, 16.5) come from earlier releases, each with the netlist, films or exports
its publisher released beside it.

`altium/` holds Altium boards as Altium saved them.  The five foxBMS boards are binary `.PcbDoc`
files.  Two OpenSpeechPlatform boards (BSD-2-Clause) come as a binary `.PcbDoc` and the ASCII
`.PcbDoc` Altium saved of the same board, with their Gerbers.

## Opening them in agni

`agni serve` can open a checkout as it stands.  `agni.yaml` at the root mounts `boards/`, `odb/`,
`cadence/`, `allegro/`, `altium/` and `house/`, so `agni check mount://boards/hackrf-one` works at the
root with no flags.
Run it from the root.  agni finds `agni.yaml` from a subfolder too, but then reads its paths against
the folder you're in.  You need agni v0.6.0 or later, the first release that reads OrCAD Capture
designs, which Clay R6 is read from.  It opens the seven binary `.PcbDoc` boards and five of the eleven Allegro `.brd` boards,
counting the two under `cadence/`.  BeaglePlay (Allegro 17.4), BeagleV-Fire (17.5), pc069, SLUGS v2,
Parallella-I and the ADALM1000 were saved by releases agni does not read yet (agni issue 1355), and
agni does not read an ASCII `.PcbDoc` yet (agni issue 1393).

```bash
make serve        # the viewer over every board, job, native board and house board, at http://127.0.0.1:8080/
make serve-wasm   # the same, with each design analysed in your browser
make site         # the whole set as static files in site/, the way agni's public demo is built
```

`AGNI` names the binary and defaults to the `agni` on your PATH.  A release binary carries the
viewer.  A dev build (`make agni` in an agni checkout) carries none, so name its `web/` too:
`make serve AGNI=../agni/bin/agni WEB_DIR=../agni/web`.  `make site` and `make serve-wasm` need the
wasm engine built there as well (`make ui wasm`).  `PORT` moves the server, and `MCP=1` also serves
agni's analysis to an agent at `/mcp`.

`serve-wasm` caps a design at serve's `--wasm-max-bytes` (128 MB).  A bigger one goes to the server
engine, and the page says so.  Jetson is about 92 MB, so every board here runs in the browser.

`make verify` checks that each board folder has a `design.yaml` and a `PROVENANCE.md` section, and
that no `project.yaml` sits over the boards.  It also checks that each folder under `allegro/`,
`odb/allegro/` and `cadence/` has a `LICENSE` and a `PROVENANCE.md` heading, and that each design
under `cadence/` has a `design.yaml`.  `make verify AGNI=agni` also reads every design, job and house
board, and fails on any that reads as no components.  `make test` checks those checks, and CI runs
both.

## Your own boards beside these

A team can clone this repo and run every analysis on its own boards, after seeing each one work on a
public board first.  `make tour` runs every target below on Glasgow.

Your boards go in their own mount, `house`.  It defaults to `house/` in the checkout, and
`HOUSE_DIR=<folder>` moves it.  A folder outside the checkout is safer, since this repo is public.
`house/README.md` walks through adding a board from the template, with a `project.yaml` for your
team's conventions, checklists and query sets.  `make setup` installs a pre-commit hook that refuses
a commit with a house board in it.

Each target runs one agni command over `DESIGN=mount://...`.  `DESIGN` defaults to Glasgow.

| target | runs |
|---|---|
| `make check` | every rule, as text, and the verdict report in `reports/<name>-check.html` |
| `make review CHECKLIST=...` | a checklist walk, and its report in `reports/`.  Defaults to `examples/checklist.yaml` |
| `make diff A=... B=...` | the structural diff of two revisions or two views.  `RENAME_APPROX=1` pairs renamed nets that also changed |
| `make query SET=...` | a query set.  Defaults to `examples/queries.yaml` |
| `make trace FROM=U1.51 TO=U14.3` | the series path between two pins |
| `make lexicon` | the vocabulary agni uses to read the design's names |
| `make pinmap` | a row for each pin in the design's `io_map`, in `reports/<name>-pins.csv` |
| `make intake` | the sanitized summary, with no net name in it |
| `make trial` | the `agni trial` report, with no name from the design in it |

`reports/` is gitignored.  Every report in it carries your net names and reference designators,
except the intake and trial reports.  `DESIGN` and the other variables in the table take a value
from the make command line only.  So if your shell exports `DESIGN` for another project's Makefile,
these targets don't see it.

## Using these from the engine

The engine fetches a **pinned release tarball**, verified by checksum, into a gitignored directory.
It does not use a git submodule, so an engine clone does not carry this repo.

Tarballs are built per purpose, so a job downloads only what it needs:

| tarball | contents |
|---|---|
| `tutorial-board` | the Jetson baseboard, schematics only |
| `oracle-corpus` | every board, schematics and board files |
| `odb-altium` | ODB++ jobs Altium Designer wrote (the foxBMS boards), byte-identical to their publisher's |
| `altium` | the same foxBMS boards as Altium saved them (`.PcbDoc`), each held to its ODB++ export in `odb-altium`, and two OpenSpeechPlatform boards saved both as binary and as ASCII `.PcbDoc` |
| `odb-kicad` | each board above exported to ODB++ by kicad-cli, for reading a board both ways |
| `allegro` | the BeagleBone AI's Allegro `.brd`, with the extract Allegro wrote from the same board |
| `cadence-exports` | ODB++ jobs Allegro's tools wrote (`odb/allegro/`), and the IPC-2581 and EDIF exports under `cadence/` |
| `allegro-boards` | nine more Allegro `.brd` boards: six with the Gerbers, drill files, netlists, placement reports and OrCAD schematics their publishers released beside them, and three whose export is in `cadence-exports` |

`make dist` builds them all and writes `SHA256SUMS`.  `make list` prints the lines to pin.  `make
verify-dist` checks a built set against its sums.

Released artifacts are the pinned ones.  Verify a download against the `SHA256SUMS` attached to the
release rather than against a local rebuild, since archive metadata varies between machines.

## Adding a board

1. **Check the licence, and stop if there is not one.**  A design shipped with no LICENSE file cannot
   be redistributed here whatever its origin.  Permissive and reciprocal open-hardware licences are
   fine (PROVENANCE.md, "Reciprocal licences").  NonCommercial terms are not.
2. Copy the design **verbatim**, including its `LICENSE` and `README.md`.  Some tests compare a read
   against the upstream tool's own output, and an edited file can't serve as that reference.
3. Drop editor state and renders (`.kicad_prl`, `.lck`, `img/`).  Keep symbol and footprint libraries,
   since resolving them is under test.
4. Add a section to `PROVENANCE.md`: upstream, source, licence, date taken, and any modification.
5. Add a `design.yaml` naming its entry and companions (agni's `agni propose <folder>` drafts one).
   The next `make serve` serves it.  Don't add a `project.yaml` above it.  agni fails to load a
   design that sits under a `project.yaml` without naming it in `extends`.
6. Run `make verify AGNI=agni`.
7. Add it to a tarball target in the `Makefile` if a test needs it.

## Licence

Each design carries its own licence, and that licence governs its design files.  The top-level
`LICENSE` (Apache-2.0) covers only what this repo adds around them.  That means the Makefile, the
scripts under `hack/`, the `examples/` and `house/` templates, the provenance records, and the
`design.yaml` descriptors and `params/` facts that agni adds to a design.
