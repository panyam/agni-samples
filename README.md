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

## Using these from the engine

The engine fetches a **pinned release tarball**, verified by checksum, into a gitignored directory.
It does not use a git submodule, so an engine clone does not carry this repo.

Tarballs are built per purpose, so a job downloads only what it needs:

| tarball | contents |
|---|---|
| `tutorial-board` | the Jetson baseboard, schematics only |
| `oracle-corpus` | every board, schematics and board files |

`make dist` builds both and writes `SHA256SUMS`.  `make list` prints the lines to pin.  `make verify`
checks a built set against its sums.

Released artifacts are the pinned ones.  Verify a download against the `SHA256SUMS` attached to the
release rather than against a local rebuild, since archive metadata varies between machines.

## Adding a board

1. **Check the licence, and stop if there is not one.**  A design shipped with no LICENSE file cannot
   be redistributed here whatever its origin.  Permissive and reciprocal open-hardware licences are
   fine.  NonCommercial terms are not.
2. Copy the design **verbatim**, including its `LICENSE` and `README.md`.  Some tests compare a read
   against the upstream tool's own output, so an edited file stops being usable as a reference.
3. Drop editor state and renders (`.kicad_prl`, `.lck`, `img/`).  Keep symbol and footprint libraries,
   since resolving them is under test.
4. Add a section to `PROVENANCE.md`: upstream, source, licence, date taken, and any modification.
5. Add it to a tarball target in the `Makefile` if a test needs it.

## Licence

Each design carries its own licence, board by board, and those govern the design files.  `LICENSE` at
the top level covers only the packaging in this repo: the makefile and the provenance records.
