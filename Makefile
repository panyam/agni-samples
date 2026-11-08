# Builds the release tarballs the agni engine fetches. It also serves the checkout, checks it, and
# runs agni's analyses over a design (see the README).
#
# The engine pins each tarball by VERSION and sha256. A published artifact must never change, but a
# rebuild needn't be bit-identical. The build is deterministic where it's cheap (sorted member
# order, zeroed ownership, no gzip timestamp), so anyone can check a release's contents against
# this tree.
#
# One tarball per PURPOSE, not one big archive, so a job downloads only what it needs. The tutorial
# ladder wants schematics for one board, and the reader cross-check wants board files for all of
# them. One 100MB download for both would slow every CI run of the engine.

VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
DIST    := dist

# Unless this is set, macOS tar writes a "._name" AppleDouble shadow beside every file it packs. A
# Finder copy can leave the same shadows on disk, and the finds below would match them by extension.
# Both are excluded. A consumer that globs *.kicad_sch would read a shadow as a schematic and fail to
# parse it (agni issue 812).
export COPYFILE_DISABLE := 1

# If tar fails in the middle of a pipe, gzip still writes a valid empty archive. So without pipefail,
# a tar that rejects a flag produces a tarball that verifies and holds nothing.
SHELL       := bash
.SHELLFLAGS := -o pipefail -ec

# Zeroed ownership, spelled for whichever tar is installed. bsdtar (macOS) and GNU tar (Linux) name
# the same flags differently.
TAR_IDS := $(shell tar --version 2>/dev/null | grep -q 'GNU tar' \
             && echo "--owner=0 --group=0 --numeric-owner" \
             || echo "--uid 0 --gid 0 --uname '' --gname ''")

.PHONY: all dist clean list verify verify-dist test setup serve serve-wasm site odb-kicad-jobs \
        check review diff query trace lexicon pinmap intake trial tour

all: dist

# Serving the checkout. AGNI is the agni binary. A release binary carries the viewer. A dev build
# (`make agni` in an agni checkout) carries none, so name its web/ too:
#   make serve AGNI=../agni/bin/agni WEB_DIR=../agni/web
# MCP=1 also serves agni's analysis to an agent at /mcp. The house mount holds a team's own boards
# (house/README.md), and HOUSE_DIR moves it to a folder outside the checkout.
#
# Every target names all six mounts, because a --mount replaces agni.yaml's whole table.
AGNI      ?= agni
PORT      ?= 8080
WEB_DIR   ?=
SITE_DIR  ?= site
HOUSE_DIR ?= house
MOUNTS    := --mount boards=boards --mount odb=odb --mount cadence=cadence --mount allegro=allegro --mount altium=altium \
             --mount house=$(HOUSE_DIR)
WEB_FLAG  = $(if $(WEB_DIR),--web-dir $(WEB_DIR))
SERVE     = $(AGNI) serve $(MOUNTS) --addr 127.0.0.1:$(PORT) $(WEB_FLAG) $(if $(MCP),--mcp)

serve:
	$(SERVE)

# The same, with each design analysed in the browser. If a design is bigger than serve's
# --wasm-max-bytes, it goes to the server engine, and the page says so.
serve-wasm:
	$(SERVE) --engine wasm

# The whole set as static files, the way agni's public demo is built, for any static server:
#   make site && python3 -m http.server -d site
# The viewer needs a web/ with the wasm engine built (`make ui wasm` in an agni checkout).
site:
	$(AGNI) site $(SITE_DIR) $(WEB_FLAG) \
	  $(foreach b,$(notdir $(wildcard boards/*)),--seed $(b)=boards/$(b)) --seed odb=odb --seed cadence=cadence

# Checks each folder's descriptor, licence and PROVENANCE.md section. hack/verify.sh says which
# folders need which. Name an agni to read every design too: make verify AGNI=agni. Without
# one the reads are skipped, since the default AGNI need not exist. `make test` checks verify itself
# the same way.
READ_AGNI = $(if $(filter command% environment%,$(origin AGNI)),$(AGNI))

verify:
	@AGNI=$(READ_AGNI) HOUSE_DIR=$(HOUSE_DIR) hack/verify.sh

test:
	@AGNI=$(READ_AGNI) hack/verify_test.sh

# Installs the pre-commit hook, which runs the same checks as make verify before every commit.
setup:
	git config core.hooksPath hack/hooks

# Analysis. Each target runs one agni command over DESIGN, a public board or a house one:
#   make check DESIGN=mount://house/my-board
# Reports go to reports/, and git ignores it. The reports carry every net name and reference
# designator, so only the intake and trial reports are meant to leave the machine.
#
# If a target would need logic beyond one agni command, agni is missing a command or a flag. File
# that in agni rather than scripting it here.
#
# These take a value from the make command line only, never from the environment. Otherwise a shell
# that exports DESIGN for another project's Makefile would aim every target here at that design.
DESIGN     = mount://boards/glasgow-revC3
CHECKLIST  = examples/checklist.yaml
SET        = examples/queries.yaml
A          =
B          =
FROM       =
TO         =
NAME       = $(notdir $(DESIGN))
REPORTS   := reports
need       = @test -n "$($(1))" || { echo "$@ needs $(1)=..." >&2; exit 2; }

$(REPORTS):
	@mkdir -p $@

# The findings as text, and the verdict report as one HTML page.
check: | $(REPORTS)
	$(AGNI) check $(MOUNTS) $(DESIGN)
	$(AGNI) check $(MOUNTS) $(DESIGN) --format html -o $(REPORTS)/$(NAME)-check.html

# A checklist walk. CHECKLIST is a manifest file, or the name of a checklist in the design's project.
review: | $(REPORTS)
	$(AGNI) review $(MOUNTS) $(DESIGN) --checklist $(CHECKLIST)
	$(AGNI) review $(MOUNTS) $(DESIGN) --checklist $(CHECKLIST) --format html -o $(REPORTS)/$(NAME)-review.html

# Two revisions, or two views of one board. RENAME_APPROX=1 also pairs nets that were renamed and
# changed.
diff:
	$(call need,A)
	$(call need,B)
	$(AGNI) diff $(MOUNTS) $(A) $(B) $(if $(RENAME_APPROX),--rename-approx)

# A query set. SET is a set file, or the name of one in the design's project queries/.
query:
	$(AGNI) query $(MOUNTS) $(DESIGN) --set $(SET)

# The series path between two pins, as <ref-des>.<pin>.
trace:
	$(call need,FROM)
	$(call need,TO)
	$(AGNI) trace $(MOUNTS) $(DESIGN) --from $(FROM) --to $(TO)

# The vocabulary agni uses to read the design's names, for the verify-lexicon skill.
lexicon:
	$(AGNI) lexicon $(MOUNTS) $(DESIGN)

# A row for each pin in the design's io_map, to sign off against the netlist and the datasheet.
pinmap: | $(REPORTS)
	$(AGNI) check $(MOUNTS) $(DESIGN) --verdicts --format csv --table pin_map -o $(REPORTS)/$(NAME)-pins.csv

# The sanitized summary: parts and rail nominals, with no net name or topology in it.
intake: | $(REPORTS)
	$(AGNI) intake $(MOUNTS) $(DESIGN) > $(REPORTS)/$(NAME)-intake.md
	@echo "wrote $(REPORTS)/$(NAME)-intake.md"

# The trial report: counts and timings, with no name from the design in it.
trial: | $(REPORTS)
	$(AGNI) trial $(MOUNTS) $(DESIGN) -o $(REPORTS)/$(NAME)-trial.md

# Every target above on Glasgow, so a team sees each output before adding a board. The trace runs
# from the microcontroller pin that enables port B's I/O supply, through R26, to the regulator's EN.
# The diff compares Glasgow's schematic with its kicad-cli ODB++ export. Glasgow's design.yaml
# declares the pin map, as Glasgow's firmware drives it.
TOUR := mount://boards/glasgow-revC3
tour:
	@echo "== check";   $(MAKE) -s check   DESIGN=$(TOUR)
	@echo "== review";  $(MAKE) -s review  DESIGN=$(TOUR)
	@echo "== query";   $(MAKE) -s query   DESIGN=$(TOUR)
	@echo "== trace";   $(MAKE) -s trace   DESIGN=$(TOUR) FROM=U1.51 TO=U14.3
	@echo "== diff";    $(MAKE) -s diff    A=$(TOUR) B=mount://odb/kicad/glasgow-revC3.odb.tgz
	@echo "== lexicon"; $(MAKE) -s lexicon DESIGN=$(TOUR)
	@echo "== intake";  $(MAKE) -s intake  DESIGN=$(TOUR)
	@echo "== trial";   $(MAKE) -s trial   DESIGN=$(TOUR)
	@echo "== pinmap";  $(MAKE) -s pinmap  DESIGN=$(TOUR)

# tutorial-board: schematics only, no board file. The docsite ladder never reads copper. The Jetson
# board file is 81MB, and shipping it here would make every tutorial CI run's download twenty times
# larger.
$(DIST)/tutorial-board-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find boards/jetson-agx-thor-baseboard -type f ! -name '._*' \
	  \( -name '*.kicad_sch' -o -name '*.kicad_pro' -o -name 'LICENSE' -o -name 'README.md' \) \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# oracle-corpus: every board, both views. The KiCad reader cross-check reads a schematic and its
# board file, and compares the two net sets. So it needs the copper, which the tutorial doesn't.
#
# Each board's params/ ships here too. Those are the datasheet facts its design.yaml names.
#
# The design.yaml descriptors ship here and NOT in tutorial-board. A descriptor names the board file
# as a companion, and agni fails a read when a declared companion is missing. So a descriptor in the
# schematics-only tarball would break every read of the tutorial board.
$(DIST)/oracle-corpus-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find boards -type f ! -name '._*' \
	  \( -name '*.kicad_sch' -o -name '*.kicad_pcb' -o -name '*.kicad_pro' -o -name '*.kicad_dru' \
	     -o -name '*.kicad_sym' -o -name '*.kicad_mod' -o -name '*-lib-table' \
	     -o -name 'design.yaml' -o -name '*.textproto' -o -name 'LICENSE' -o -name 'README.md' \) \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# odb-altium: ODB++ jobs Altium Designer wrote, byte-identical to their publisher's (foxBMS). agni's
# gate reads them for parts of the format that KiCad's exporter never writes. This tarball is kept
# small enough to fetch on every CI run.
$(DIST)/odb-altium-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/altium -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# odb-kicad: each KiCad board above, exported to ODB++ by kicad-cli (odb-kicad-jobs). agni reads a
# board both ways and requires the two reads to agree. That check needs oracle-corpus beside it, so
# this tarball ships apart from the gate's artifacts.
$(DIST)/odb-kicad-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/kicad -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# allegro: Allegro boards, byte-identical to their publishers'. Each comes with an extract that
# Allegro wrote from the same board. agni's Allegro reader is held to the extract, so the two ship
# together.
ALLEGRO_EXTRACT_BOARDS := allegro/beaglebone-ai
$(DIST)/allegro-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find $(ALLEGRO_EXTRACT_BOARDS) -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# allegro-boards: the other Allegro boards. Six come with other files their publishers released
# beside them (Gerbers and drill, a netlist, a placement report, the OrCAD schematic). The other three
# have an ODB++ job of the same board in cadence-exports. A read of each .brd is checked against
# those files. The boards come to about 125MB unpacked, so they ship apart from allegro. A job that
# needs only the extract-backed board fetches less.
$(DIST)/allegro-boards-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find allegro -type f ! -name '._*' $(foreach b,$(ALLEGRO_EXTRACT_BOARDS),! -path '$(b)/*') \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# altium: the foxBMS boards as Altium Designer saved them (.PcbDoc), byte-identical to their
# publisher's. Each board's ODB++ export is in odb-altium, so agni's .PcbDoc reader is held to it.
$(DIST)/altium-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find altium -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# cadence-exports: designs that Cadence's tools exported in formats agni reads today, byte-identical
# to their publishers'. The ODB++ jobs from Allegro sit under odb/allegro/, beside odb/altium/. The
# IPC-2581 and EDIF exports sit under cadence/, each with a design.yaml, beside the 16.6 board and
# netlist each one is checked against. Clay R6 also carries Capture's own .DSN files, which agni
# reads from panyam/agni#1399.
$(DIST)/cadence-exports-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/allegro cadence -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

dist: $(DIST)/tutorial-board-$(VERSION).tar.gz $(DIST)/oracle-corpus-$(VERSION).tar.gz \
      $(DIST)/odb-altium-$(VERSION).tar.gz $(DIST)/odb-kicad-$(VERSION).tar.gz \
      $(DIST)/allegro-$(VERSION).tar.gz $(DIST)/allegro-boards-$(VERSION).tar.gz \
      $(DIST)/cadence-exports-$(VERSION).tar.gz $(DIST)/altium-$(VERSION).tar.gz
	@cd $(DIST) && shasum -a 256 *-$(VERSION).tar.gz > SHA256SUMS
	@echo
	@echo "built $(VERSION):"
	@ls -lh $(DIST)/*-$(VERSION).tar.gz | awk '{printf "  %-46s %s\n", $$9, $$5}'
	@echo
	@cat $(DIST)/SHA256SUMS

# What the engine pins. Paste the lines for the tarballs it fetches into its hack/samples.pin.
list: dist
	@echo
	@echo "engine pin:"
	@awk '{printf "  %s  %s\n", $$1, $$2}' $(DIST)/SHA256SUMS

verify-dist:
	@cd $(DIST) && shasum -a 256 -c SHA256SUMS
	@for f in $(DIST)/*-$(VERSION).tar.gz; do \
	  if tar -tzf $$f | grep -q '\(^\|/\)\._'; then echo "$$f carries AppleDouble files"; exit 1; fi; \
	done

clean:
	rm -rf $(DIST)

# Regenerates odb/kicad from the boards, with KiCad 9 or later. Precision 6 writes coordinates to the
# nanometre. The exporter stamps the time it ran into two files of each job. Those stamps are fixed,
# so a regeneration with no board change rewrites nothing that matters. The exporter also leaves a
# .kicad_prl beside a board that had none, and that file is removed.
ODB_BOARDS := $(shell find boards -name '*.kicad_pcb' ! -path '*/nfc_antenna/*' | sort)
odb-kicad-jobs:
	@command -v kicad-cli >/dev/null || { echo "kicad-cli not found" >&2; exit 1; }
	@mkdir -p odb/kicad
	@for b in $(ODB_BOARDS); do \
	  name=$$(basename $$(dirname $$b)); tmp=$$(mktemp -d); \
	  prl=$${b%.kicad_pcb}.kicad_prl; had=0; [ -e "$$prl" ] && had=1; \
	  kicad-cli pcb export odb --compression none --precision 6 -o $$tmp/$$name $$b >/dev/null; \
	  [ $$had = 1 ] || rm -f "$$prl"; \
	  find $$tmp/$$name -type f -print0 | xargs -0 perl -pi -e \
	    's/^# \d{4}-\d\d-\d\dT\d\d:\d\d:\d\d$$/# 2026-01-01T00:00:00/; s/^(CREATION|SAVE)_DATE=.*/$$1_DATE=20260101.000000/'; \
	  (cd $$tmp && find $$name -type f | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9) > odb/kicad/$$name.odb.tgz; \
	  rm -rf $$tmp; echo "wrote odb/kicad/$$name.odb.tgz"; \
	done
