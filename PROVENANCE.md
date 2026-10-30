# Provenance

One section per board: who published it, under what terms, and what was changed.

The modification line is the one that matters.  Some agni tests compare a read of a design against the
output of the tool that produced it, so an edited file stops being usable as a reference.  The
expected answer is "none".

## jetson-agx-thor-baseboard

| | |
|---|---|
| Upstream | Antmicro, baseboard for NVIDIA Jetson AGX Thor |
| Source | shipped in the KiCad 9 `demos/` directory; upstream project by [Antmicro](https://antmicro.com) |
| Licence | Apache-2.0 (`boards/jetson-agx-thor-baseboard/LICENSE`) |
| Copyright | (c) 2025-2026 Antmicro |
| Taken | 2026-09-07, from a KiCad 9 installation |
| Modifications | **None.**  Design files are byte-identical to upstream. |
| Not included | the `img/` renders from the upstream repo |
| Added | `design.yaml`, agni's descriptor (Apache-2.0): the entry, the board as a companion, and which connectors are internal to the product |

17 sheets, 1123 components, 1387 nets as KiCad resolves them.  Carries I2C, MDIO, PCIe, USB, CSI and
DisplayPort, and an `MPN` property on every footprint.

## royalblue54L-feather

| | |
|---|---|
| Upstream | RoyalBlue54L Feather, an ARM + RISC-V Feather board (nRF54L15) |
| Source | shipped in the KiCad 9 `demos/` directory |
| Licence | CERN-OHL-P v2, permissive (`boards/royalblue54L-feather/LICENSE`) |
| Taken | 2026-09-07, from a KiCad 9 installation |
| Modifications | **None** to any design file. |
| Not included | `img/` renders, `.kicad_prl` and `.lck` editor state |
| Added | `design.yaml` beside the Feather and beside the NFC antenna, agni's descriptors (Apache-2.0). The Feather's declares no board, because its `.kicad_pcb` does not parse (agni issue 681) |

71 components on one sheet, with its symbol libraries in `lib/` and a `sym-lib-table`.

## hackrf-one

| | |
|---|---|
| Upstream | HackRF One, a wideband software-defined radio, by Great Scott Gadgets |
| Source | [greatscottgadgets/hackrf](https://github.com/greatscottgadgets/hackrf), `hardware/hackrf-one/`, commit `468c5d93` |
| Licence | CERN-OHL-P v2, permissive (`boards/hackrf-one/LICENSE`, the hardware folder's own; the repo's GPL covers the firmware) |
| Copyright | (c) 2012-2022 Great Scott Gadgets |
| Taken | 2026-10-30 |
| Modifications | **None** to any design file. |
| Not included | `acrylic_case/` and `PlasticCase_CAD/` enclosure drawings, `.kicad_prl` editor state |
| Added | `design.yaml`, agni's descriptor (Apache-2.0) |

KiCad 6 format (schematic `20211123`, board `20211014`). 4 sheets, 418 components, 379 nets as KiCad
10 resolves them.

## glasgow-revC3

| | |
|---|---|
| Upstream | Glasgow Interface Explorer, revision C3 (the revision that shipped) |
| Source | [GlasgowEmbedded/glasgow](https://github.com/GlasgowEmbedded/glasgow), `hardware/boards/glasgow/revC3/`, commit `d0fbcf28` |
| Licence | 0BSD (`boards/glasgow-revC3/LICENSE`, copied from the repo root's `LICENSE-0BSD.txt`) |
| Copyright | (c) Glasgow Interface Explorer contributors |
| Taken | 2026-10-30 |
| Modifications | **None** to any design file. |
| Not included | `output/` fabrication outputs and renders, `.kicad_prl`. The shared `hardware/symbols` and `hardware/footprints` libraries the lib tables name at `../../` are not included; the schematic embeds every symbol it places and the board every footprint |
| Added | `design.yaml`, agni's descriptor (Apache-2.0); `README.md` is the repo root's |

KiCad 7 format (`20230121`). 3 sheets, 257 components, 251 nets as KiCad 10 resolves them.

## cynthion

| | |
|---|---|
| Upstream | Cynthion, a USB test instrument, by Great Scott Gadgets |
| Source | [greatscottgadgets/cynthion-hardware](https://github.com/greatscottgadgets/cynthion-hardware), repo root, commit `13aa71c2` |
| Licence | CERN-OHL-P v2, permissive (`boards/cynthion/LICENSE`) |
| Copyright | (c) 2019-2024 Great Scott Gadgets |
| Taken | 2026-10-30 |
| Modifications | **None** to any design file. |
| Not included | `.kicad_prl`, the repo's `.gitignore` |
| Added | `design.yaml`, agni's descriptor (Apache-2.0) |

KiCad 7 format (`20230121`). 17 sheets, 348 components, 375 nets as KiCad 10 resolves them.

## mnt-reform-motherboard30

| | |
|---|---|
| Upstream | MNT Reform 2 motherboard, version 3.0, by MNT Research |
| Source | [source.mnt.re/reform/reform](https://source.mnt.re/reform/reform), `reform2-motherboard30-pcb/`, commit `9dcb9a8d` |
| Licence | CERN-OHL-S v2, strongly reciprocal (`boards/mnt-reform-motherboard30/LICENSE`, copied from the repo's `LICENSES/`) |
| Copyright | (c) 2018-2020 MNT Research GmbH |
| Taken | 2026-10-30 |
| Modifications | **None** to any design file. |
| Not included | `3d-models/` (95MB of STEP files), `graphics/` silkscreen artwork, `.kicad_prl` |
| Added | `design.yaml`, agni's descriptor (Apache-2.0); `README.md` is the repo root's, which states the licences and the MNT trademark terms |

KiCad 8 format (`20231120`). 13 sheets, 529 components, 681 nets as KiCad 10 resolves them. The
"MNT" and "MNT Reform" marks are MNT Research's trademarks and are not licensed by CERN-OHL-S; the
files are redistributed unmodified, which is what the marks permit.

## Reciprocal licences

A strongly reciprocal licence (CERN-OHL-S, GPL) obliges whoever distributes a MODIFIED design or a
product made from it to release their changes under the same terms. This repo redistributes the
designs unmodified with their licence, which every one of these licences allows, and agni reading a
design in a test makes agni neither a modification nor a product of it. So reciprocal boards are
accepted. This reverses the earlier exclusion of `cm5_minima`, which can be added the same way.

## Boards not included

Other designs were considered and left out.  Recorded here so the survey is not repeated.

| board | reason |
|---|---|
| `pic_programmer`, `complex_hierarchy`, `video`, `interf_u`, `kit-dev-coldfire-xilinx_5213` | no LICENSE file, so nothing grants redistribution |
| `stickhub` | CC BY-NC-SA, NonCommercial |
| `openair-max` | CC BY-SA |
| Framework Laptop expansion cards | CC-BY-4.0 and fine to ship, but KiCad 5 format, which agni does not read |

A test needing one of these should read it from a local KiCad installation and skip loudly when it is
absent, never silently.
