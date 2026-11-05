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
| Added | `design.yaml`, agni's descriptor (Apache-2.0); `README.md` is the repo root's; `params/tpd3s014.textproto` (Apache-2.0), facts transcribed by hand from TI's TPD3S0x4 datasheet SLVSCP4B (revised August 2015), each citing its page; an `io_map` in `design.yaml`, the FX2's pin assignments as Glasgow's firmware makes them (`firmware/fx2/glasgow_gpio.h` at the same commit) |

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

## ODB++ jobs (`odb/`)

### foxBMS boards, written by Altium Designer (`odb/altium/foxbms/`)

| | |
|---|---|
| Upstream | foxBMS 1, the battery management system by Fraunhofer IISB |
| Source | https://github.com/foxBMS/foxbms-1, `hardware/<board>/<board>.zip` at commit `e6c9a20e6fbc`, the member `Fabrication/odb++/<name>.zip` |
| Licence | CC-BY-4.0 (`odb/altium/foxbms/LICENSE`), the licence foxBMS states for its hardware and documentation |
| Attribution | This product uses parts of foxBMS® (the phrase foxBMS asks for). |
| Taken | 2026-10-30 |
| Modifications | **None.**  Each `<board>.odb.zip` is the published ODB++ archive, byte-identical, renamed for the board it belongs to. |
| Not included | the Altium sources, schematics PDFs, BOMs and Gerbers in the same packages |

Five boards (extension, interface, master, the two slaves), 74 to 591 parts, 11 to 14 layers. They are
the engine's first ODB++ jobs from a tool other than KiCad, so agni's gate reads them for the dialect
KiCad's exporter never writes: feature groups, through-hole pads, silkscreen text records, no
`misc/info`.

### KiCad boards, exported by kicad-cli (`odb/kicad/`)

| | |
|---|---|
| Upstream | the boards under `boards/`, each under its own licence above |
| Made with | `kicad-cli pcb export odb --compression none --precision 6`, KiCad 10.0.6 (`make odb-kicad-jobs`) |
| Modifications | **Derived.**  Each is KiCad's export of the board beside it, with the two export timestamps fixed so a regeneration is stable.  Its licence is the board's. |

agni reads each board from its `.kicad_pcb` and from its export and requires the two to agree, so
the source of the export is also its oracle.

## Allegro boards (`allegro/`)

### BeagleBone AI (`allegro/beaglebone-ai/`)

| | |
|---|---|
| Upstream | BeagleBone AI, by BeagleBoard.org |
| Source | [beagleboard/beaglebone-ai](https://github.com/beagleboard/beaglebone-ai), `HW/BeagleBone-AI.brd` and `HW/cds2f_BeagleBone-AI.txt`, commit `819b6268` |
| Licence | CC-BY-4.0 (`allegro/beaglebone-ai/LICENSE`, the repo's own) |
| Copyright | (c) 2019 Jason Kridner, Texas Instruments; (c) 2019 Embest Technology Co., Ltd.; (c) 2020 Seeed Technology Co., Ltd |
| Taken | 2026-11-05 |
| Modifications | **None.**  Both files are byte-identical to upstream. |
| Not included | the OrCAD schematic (`.dsn`), the RevA2 board, Gerbers, BOMs and PDFs |

An Allegro 17.2 board: 716 components, 12 copper layers. `cds2f_BeagleBone-AI.txt` is an Allegro
extract written from this board, as its `J!` header row records. It lists each component's placement,
each pin's net, name and position, the vias and their nets, and the padstacks per layer, so agni's
Allegro reader is held to it.

### The other Allegro boards

No publisher released an extract for these three, so they ship in `allegro-boards` with the files
Allegro wrote beside each board. A `.brd` read can be checked against those: copper and holes
against the Gerbers and drill files, and part positions against a placement report.

Each `.brd` opens with a 4-byte header word. BeagleBoard's Allegro boards use three of them, and
these three boards are one of each. The BeagleBone AI above and the AI-64 share `00 04 14 00`, the
header of a board the section above records as Allegro 17.2. BeaglePlay has `02 09 14 00`, which BeagleV-Ahead and PocketBeagle
2 share. BeagleV-Fire has `02 15 14 00`, which BeagleY-AI shares. The `.brd` files carry no readable
version string. The Gerbers name their writer: Allegro 17.4-S032 for BeaglePlay and 17.4-S031 for
BeagleV-Fire, so both later headers come from 17.4 builds.

Files keep their upstream paths under each board's folder. Allegro's numbered backups
(`art_param.txt,1`, `nc_param.txt,1`) are left out as editor state.

### BeaglePlay (`allegro/beagleplay/`)

| | |
|---|---|
| Upstream | BeaglePlay, by BeagleBoard.org |
| Source | [beagleboard/beagleplay](https://github.com/beagleboard/beagleplay), commit `7a59a98a` |
| Licence | CC-BY-4.0 (`allegro/beagleplay/LICENSE`, the repo's own) |
| Copyright | (c) 2023 Seeed Technology Co., Ltd; (c) 2023 BeagleBoard.org Foundation |
| Taken | 2026-11-05 |
| Files | `Design/20230215_beagleplayv022_10.brd`, the OrCAD schematic `Design/BEAGLEPLAYV10_221227.DSN`, the Gerbers, drill and route files in `MFG/gerber_beagleplayv022_230215/`, and `BeaglePlay_bom.csv` |
| Modifications | **None.**  Every file is byte-identical to upstream, checked against its git blob hash. |
| Not included | PDFs, the placement spreadsheet, certification reports, and the two `,1` backups |

`.brd` header `02 09 14 00`. 8 copper layers (`L1_top` to `L8_bottom`). The Gerbers record
"Cadence Allegro 17.4-S032", written 2023-02-15.

### BeagleV-Fire (`allegro/beaglev-fire/`)

| | |
|---|---|
| Upstream | BeagleV-Fire, by BeagleBoard.org |
| Source | [beagleboard/beaglev-fire](https://github.com/beagleboard/beaglev-fire), commit `cdbd4b68` |
| Licence | CC-BY-4.0 (`allegro/beaglev-fire/LICENSE`, the repo's own) |
| Copyright | (c) 2023 Seeed Technology Co., Ltd; (c) 2023 BeagleBoard.org Foundation |
| Taken | 2026-11-05 |
| Files | `design/BeagleV-FIRE_REV-A_230911.brd`, the OrCAD schematic `design/BeagleV-FIRE_REV-A_230911.DSN`, the Gerbers, drill and route files in `design/gerbers/`, and `design/BeagleV-Fire_BOM.csv` |
| Modifications | **None.**  Every file is byte-identical to upstream, checked against its git blob hash. |
| Not included | PDFs, 3D models, and the two `,1` backups |

`.brd` header `02 15 14 00`. 12 copper layers (`TOP`, `LAY2_GND` to `LAY11_GND`, `BOTTOM`). The Gerbers
record "Cadence Allegro 17.4-S031", written 2023-09-26.

### BeagleBone AI-64 (`allegro/beaglebone-ai-64/`)

| | |
|---|---|
| Upstream | BeagleBone AI-64, Rev B1, by BeagleBoard.org |
| Source | [beagleboard/beaglebone-ai-64](https://github.com/beagleboard/beaglebone-ai-64), commit `7313ca3c` |
| Licence | CC-BY-4.0 (`allegro/beaglebone-ai-64/LICENSE`, the repo's own) |
| Copyright | (c) 2021-2022 BeagleBoard.org Foundation; (c) 2021-2022 Seeed Technology Co., Ltd |
| Taken | 2026-11-05 |
| Files | `hw/BeagleBone_AI-64_Rev_B1_PCB_220602.brd`, the placement report `hw/BeagleBone_AI-64_Rev_B1_ASSY_XY_220602.csv`, and `hw/BeagleBone_AI-64_Rev_B1_BOM_220602.csv` |
| Modifications | **None.**  Every file is byte-identical to upstream, checked against its git blob hash. |
| Not included | the OrCAD schematic (`.DSN`, 30MB), the PDF schematic and the TI documentation |

`.brd` header `00 04 14 00`. The placement report is Allegro's Component Report: 1166 components, each
with its device, package, position, rotation and side.

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
