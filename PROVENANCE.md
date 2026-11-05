# Provenance

One section per design: who published it, under what terms, and what was changed.

Read the modification line first.  Some agni tests compare a read of a design against the output of
the tool that produced it, and an edited file can't serve as that reference.  So the expected
answer is "none".

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
"MNT" and "MNT Reform" marks are MNT Research's trademarks, and CERN-OHL-S doesn't license them. The
trademark terms permit redistributing the files unmodified, and this repo does only that.

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

Five boards: extension, interface, master, and the two slaves. They have 74 to 591 parts and 11 to 14
layers. They were the engine's first ODB++ jobs from a tool other than KiCad. agni's gate reads them
for parts of the format that KiCad's exporter never writes, such as feature groups, through-hole
pads and silkscreen text records, and for a job with no `misc/info`.

### foxBMS boards as Altium saved them (`altium/foxbms/`)

| | |
|---|---|
| Upstream | foxBMS 1, the battery management system by Fraunhofer IISB |
| Source | https://github.com/foxBMS/foxbms-1, `hardware/<board>/<board>.zip` at commit `e6c9a20e6fbc`, the member `Sources/<name>.PcbDoc` |
| Licence | CC-BY-4.0 (`altium/foxbms/LICENSE`), the licence foxBMS states for its hardware and documentation |
| Attribution | This product uses parts of foxBMS® (the phrase foxBMS asks for). |
| Taken | 2026-11-05 |
| Modifications | **None.**  Each `.PcbDoc` is byte-identical to the member of its board's package. |
| Not included | the schematics (`.SchDoc`), the project and variant files, PDFs and assembly files |

The same five boards as `odb/altium/foxbms/`, as binary Altium board files. Each board's package
holds its `.PcbDoc` and its ODB++ job side by side, and the job is byte-identical to the one in
`odb-altium`. So agni's `.PcbDoc` reader is held to Altium's own export of the same board
(panyam/agni#1349).

### KiCad boards, exported by kicad-cli (`odb/kicad/`)

| | |
|---|---|
| Upstream | the boards under `boards/`, each under its own licence above |
| Made with | `kicad-cli pcb export odb --compression none --precision 6`, KiCad 10.0.6 (`make odb-kicad-jobs`) |
| Modifications | **Derived.**  Each is KiCad's export of the board beside it, with the two export timestamps fixed so a regeneration is stable.  Its licence is the board's. |

agni reads each board twice, from its `.kicad_pcb` and from its export, and requires the two reads to
agree. So the board each export came from also serves as its oracle.

### Allegro jobs (`odb/allegro/`)

These ODB++ jobs came out of Cadence Allegro. Each is byte-identical to the file its publisher
released. Each was checked against git's blob hash, and the Git LFS one against its pointer's sha256.
Each job's `misc/info` names an Allegro extract as its source. The `SAVE_APP` line names the tool
that wrote the job file itself, and it differs across the three. One was Allegro's own ODB++ writer,
and the other two were Valor tools that turn an Allegro extract into a job. Each file is renamed to
`<name>.odb.tgz`, following the convention in `odb/`.

### pc069 rev c, written by Allegro (`odb/allegro/pc069/`)

| | |
|---|---|
| Upstream | DUNE Timing System reference hardware FMC (pc069), University of Bristol HEP |
| Source | [uob-hep-cad/uob-hep-pc069](https://github.com/uob-hep-cad/uob-hep-pc069), `hardware/Manufacturing/artwork/pc069c_25-manufacturing-artwork-2025-02-06/pc069c_toplevel_25.tgz`, commit `d86f9c06` |
| Licence | CERN-OHL-S-2.0 (`odb/allegro/pc069/LICENSE`, the repo's own) |
| Taken | 2026-11-05 |
| Modifications | **None.**  Renamed to `pc069c_toplevel_25.odb.tgz`. |
| Not included | the `.brd`, the `pst*.dat` packager netlist, the PDFs, and the older pc069b_16 and pc069c_23 jobs |

`SAVE_APP=ODB++ Cadence Allegro 2409.0000`, written 2025-02-06, ODB++ 8. agni reads 197 components,
123 nets and 19 layers.

### OpenCellular breakout board (`odb/allegro/opencellular-breakout/`)

| | |
|---|---|
| Upstream | OpenCellular Connect-1 breakout board, Telecom Infra Project |
| Source | [Telecominfraproject/OpenCellular](https://github.com/Telecominfraproject/OpenCellular), `electronics/breakout/odb++/odbjob.tgz`, commit `0d5d7b00` |
| Licence | CC-BY-4.0 (`odb/allegro/opencellular-breakout/LICENSE`, the repo's `LICENSE-HARDWARE`) |
| Taken | 2026-11-05 |
| Modifications | **None.**  Renamed to `opencellular-breakout.odb.tgz`. |
| Not included | the `.brd`, the OrCAD `.DSN`, and the repo's other ten ODB++ jobs. Two of those came from Xpedition and PADS rather than Allegro |

`SAVE_APP=ODB++ Viewer 9.6`, written 2017-01-05, ODB++ 8. agni reads 68 components, 75 nets and 15
layers.

### Zaius LOM/VGA card (`odb/allegro/zaius-lv-card/`)

| | |
|---|---|
| Upstream | Zaius / Barreleye G2 LOM and VGA card (EVT), contributed to the Open Compute Project |
| Source | [opencomputeproject/zaius-barreleye-g2](https://github.com/opencomputeproject/zaius-barreleye-g2), `HW/EE/GBR/EVT/LOM_VGA Card/Zaius-EVT-LAYOUT-LV_Card-ODB-X00-20160824-Final.zip` (Git LFS), commit `125c5c26` |
| Licence | OCP Hardware License-Permissive 1.0 (`odb/allegro/zaius-lv-card/LICENSE`, the repo's `license.md`) |
| Taken | 2026-11-05 |
| Modifications | **None** to the job.  The upstream zip is a release package holding the job as `Zaius-EVT-LV_Card-X00_V6.tgz` beside two PDFs. That inner file is kept with its bytes unchanged, renamed to `zaius-lv-card.odb.tgz` (sha256 `d91d00a1`). |
| Not included | the package's two PDFs (the PCBA drawing and the stackup report), and the repo's four other jobs, 6 to 64MB each |

`SAVE_APP=Valor NPI 9.2.0 Update 1`, written 2016-08-24, ODB++ 6. agni reads 34 components, 39 nets
and 12 layers.

## Allegro boards (`allegro/`)

### BeagleBone AI (`allegro/beaglebone-ai/`)

| | |
|---|---|
| Upstream | BeagleBone AI, by BeagleBoard.org |
| Source | [beagleboard/beaglebone-ai](https://github.com/beagleboard/beaglebone-ai), `HW/BeagleBone-AI.brd`, `HW/cds2f_BeagleBone-AI.txt`, and the twelve copper films and `photoplot.log` in `MFG/`, commit `819b6268` |
| Licence | CC-BY-4.0 (`allegro/beaglebone-ai/LICENSE`, the repo's own) |
| Copyright | (c) 2019 Jason Kridner, Texas Instruments; (c) 2019 Embest Technology Co., Ltd.; (c) 2020 Seeed Technology Co., Ltd |
| Taken | 2026-11-05 |
| Modifications | **None.**  Every file is byte-identical to upstream. |
| Not included | the OrCAD schematic (`.dsn`), the RevA2 board, the mask, paste, silk, assembly and drill films, BOMs and PDFs |

An Allegro 17.2 board, with 716 components and 12 copper layers. Allegro wrote
`cds2f_BeagleBone-AI.txt` from this board, as the extract's `J!` header row records. It lists each
component's placement, and each pin's net, name and position. It also lists the vias with their nets,
and the padstacks on each layer. agni's Allegro reader is held to it.

`MFG/` holds the copper films Allegro 17.2-S049 plotted from this board, one per layer, as
`photoplot.log` records. agni holds each copper layer it reads to its film (panyam/agni#1376).

### The other Allegro boards

No publisher released an extract for these three. So they ship in `allegro-boards` with the other
files Allegro wrote beside each board, and a `.brd` read can be checked against those. The Gerbers
and drill files check copper and holes, and a placement report checks part positions.

Each `.brd` opens with a 4-byte header word. BeagleBoard's Allegro boards use three of them, and
these three boards have one each. The AI-64 shares `00 04 14 00` with the BeagleBone AI, and the
section above records the BeagleBone AI as Allegro 17.2. BeaglePlay has `02 09 14 00`, and so do
BeagleV-Ahead and PocketBeagle 2. BeagleV-Fire has `02 15 14 00`, and so does BeagleY-AI. The `.brd`
files carry no readable version string. The Gerbers name their writer, Allegro 17.4-S032 for
BeaglePlay and 17.4-S031 for BeagleV-Fire, so both later headers come from 17.4 builds.

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

### Allegro boards with their own export

The publisher of each of these boards also released an export of the same board. Those exports ship
in the `cadence-exports` tarball, and a `.brd` read can be held to its export, pin by pin and net by
net. Each file is byte-identical to upstream, checked against git's blob hash. Each board's `LICENSE`
is a copy of the one beside its export, since both come from the same repo. Their header words add
three more families to the three above.

### pc069 rev c board (`allegro/pc069/`)

| | |
|---|---|
| Source | [uob-hep-cad/uob-hep-pc069](https://github.com/uob-hep-cad/uob-hep-pc069), `hardware/Cadence/worklib/pc069c_toplevel/physical/pc069c_toplevel_25.brd`, commit `d86f9c06` |
| Licence | CERN-OHL-S-2.0 |
| Paired with | `odb/allegro/pc069/pc069c_toplevel_25.odb.tgz`, the ODB++ job of the same revision, 25 |
| Not included | revisions 19 to 24, the `EDA-02319` and `alinx_acau15_carrier` boards beside it |

`.brd` header `00 02 15 00`. Its job was written by Allegro 2409.

### OpenCellular breakout board (`allegro/opencellular-breakout/`)

| | |
|---|---|
| Source | [Telecominfraproject/OpenCellular](https://github.com/Telecominfraproject/OpenCellular), `electronics/breakout/board/OC_CONNECT-1_BREAKOUT_LIFE-3.brd`, commit `0d5d7b00` |
| Licence | CC-BY-4.0 |
| Paired with | `odb/allegro/opencellular-breakout/opencellular-breakout.odb.tgz` |

`.brd` header `04 15 13 00`.

### Parallella parasdr board (`allegro/parallella-parasdr/`)

| | |
|---|---|
| Source | [parallella/parallella-hw](https://github.com/parallella/parallella-hw), `parasdr/src/parasdr_layout.brd`, commit `a6bcdf84` |
| Licence | CC BY-SA 3.0 US |
| Paired with | `cadence/parallella-parasdr/parasdr_ipc2581.xml`, and the ODB++X beside it |

`.brd` header `03 15 13 00`. Its ODB++X names Allegro SPB 16.6.

## Cadence exports (`cadence/`)

These are designs as Cadence's tools exported them, in formats agni reads today. Each has a
`design.yaml` that names the export as its entry, so the `cadence` mount serves it like a board.

### Parallella parasdr (`cadence/parallella-parasdr/`)

| | |
|---|---|
| Upstream | Parallella parasdr, a software-defined radio board from the Parallella project |
| Source | [parallella/parallella-hw](https://github.com/parallella/parallella-hw), `parasdr/mfg/parasdr_ipc2581.xml` and `parasdr/mfg/parasdr_odb++.xml`, commit `a6bcdf84` |
| Licence | CC BY-SA 3.0 US (`cadence/parallella-parasdr/LICENSE`, the repo's own) |
| Copyright | (c) 2016 Parallella Foundation |
| Taken | 2026-11-05 |
| Modifications | **None.**  Both files are byte-identical to upstream. |
| Not included | the `.brd`, Gerbers, and the repo's four Allegro ODB++ jobs for its other boards |
| Added | `design.yaml`, agni's descriptor (Apache-2.0) |

`parasdr_ipc2581.xml` is IPC-2581 revision B. Its header names `<SoftwarePackage name="Allegro"
vendor="Cadence">`. agni reads 404 components, 157 nets and 19 layers. `parasdr_odb++.xml` holds the
same board as ODB++X (ODX). "UNDISCLOSED Allegro SPB16.6" wrote it on 2014-08-22. agni has no ODX
reader yet, so the descriptor doesn't name it. Once agni can read ODX, each file can check the other
against the same board.

### Clay R6 (`cadence/clay-r6/`)

| | |
|---|---|
| Upstream | Clay, revision 6, by Michael Gubbels |
| Source | [ah-cog/Clay](https://github.com/ah-cog/Clay), `Circuit/R6_1/CLAYR6.EDF` and `Circuit/R6_1/allegro/CLAYR6.brd`, commit `31a84237` |
| Licence | MIT (`cadence/clay-r6/LICENSE`, the repo's own) |
| Copyright | (c) 2014 Michael Gubbels |
| Taken | 2026-11-05 |
| Modifications | **None.**  Both files are byte-identical to upstream. |
| Not included | the OrCAD `.DSN`, the earlier revisions' boards and Gerbers, and the firmware |
| Added | `design.yaml`, agni's descriptor (Apache-2.0) |

EDIF 2.0.0 from OrCAD Capture: `program "cap2edif"`, `dataOrigin "OrCAD Capture"`, SPB 16.60. agni
reads 74 components and 52 nets. `CLAYR6.brd` (added 2026-11-05, SHA-256 `31784808...5f694f`) is the
same revision's Allegro board, header `03 15 13 00`, which is Allegro 16.6. Its EDIF is its second
view, so it is the board agni's cross-probe walk runs on for an EDIF design (panyam/agni#1382), once
agni reads 16.6 (panyam/agni#1355).

## Reciprocal licences

Suppose someone distributes a MODIFIED design under a strongly reciprocal licence (CERN-OHL-S, GPL),
or a product made from one. That licence obliges them to release their changes under the same terms.
This repo redistributes the designs unmodified, with their licence, and every one of these licences
allows that. agni reading a design in a test doesn't make agni a modification of it, or a product of
it. So reciprocal boards are accepted. This reverses the earlier exclusion of `cm5_minima`, which can
be added the same way.

## Boards not included

These designs were considered and left out.  They're recorded here so nobody repeats the survey.

| board | reason |
|---|---|
| `pic_programmer`, `complex_hierarchy`, `video`, `interf_u`, `kit-dev-coldfire-xilinx_5213` | no LICENSE file, so nothing grants redistribution |
| `stickhub` | CC BY-NC-SA, NonCommercial |
| `openair-max` | CC BY-SA, left out as reciprocal before "Reciprocal licences" above reversed that rule |
| Framework Laptop expansion cards | CC-BY-4.0 and fine to ship, but KiCad 5 format, which agni does not read |

If a test needs one of these, it should read it from a local KiCad installation. When the file is
absent, the test should skip loudly, never silently.
