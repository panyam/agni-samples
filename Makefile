# Build the release tarballs the agni engine fetches.
#
# The engine pins each tarball by VERSION and sha256, so what matters here is that a published
# artifact never changes, not that a rebuild is bit-identical. Best-effort determinism anyway
# (sorted member order, zeroed ownership, no gzip timestamp), so anyone can check a release against
# this tree.
#
# One tarball per PURPOSE, not one big archive. A job downloads what it needs: the tutorial ladder
# wants schematics for one board, the reader cross-check wants board files for all of them, and
# making that the same 100MB download would be a tax on every CI run of the engine.

VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
DIST    := dist

# macOS tar writes a "._name" AppleDouble shadow beside every file it packs unless this is set, and
# a Finder copy can leave the same shadows on disk, where the find below would match them by
# extension. Both are excluded, because a consumer globbing *.kicad_sch reads a shadow as a
# schematic and fails to parse it (agni issue 812).
export COPYFILE_DISABLE := 1

# A failing tar in the middle of a pipe still lets gzip write a valid empty archive, so without
# pipefail a tar that rejects a flag produces a tarball that verifies and holds nothing.
SHELL       := bash
.SHELLFLAGS := -o pipefail -ec

# Zeroed ownership, spelled for whichever tar is installed: bsdtar (macOS) and GNU tar (Linux) name
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
# MCP=1 also serves agni's analysis to an agent at /mcp. HOUSE_DIR moves the house mount, a team's
# own boards (house/README.md), to a folder outside the checkout.
#
# Every target names all four mounts, because a --mount replaces agni.yaml's whole table.
AGNI      ?= agni
PORT      ?= 8080
WEB_DIR   ?=
SITE_DIR  ?= site
HOUSE_DIR ?= house
MOUNTS    := --mount boards=boards --mount odb=odb --mount cadence=cadence --mount house=$(HOUSE_DIR)
WEB_FLAG  = $(if $(WEB_DIR),--web-dir $(WEB_DIR))
SERVE     = $(AGNI) serve $(MOUNTS) --addr 127.0.0.1:$(PORT) $(WEB_FLAG) $(if $(MCP),--mcp)

serve:
	$(SERVE)

# The same, with each design analysed in the browser. A design over serve's --wasm-max-bytes goes to
# the server engine, and the page says so.
serve-wasm:
	$(SERVE) --engine wasm

# The whole set as static files, the way agni's public demo is built, for any static server:
#   make site && python3 -m http.server -d site
# The viewer needs a web/ with the wasm engine built (`make ui wasm` in an agni checkout).
site:
	$(AGNI) site $(SITE_DIR) $(WEB_FLAG) \
	  $(foreach b,$(notdir $(wildcard boards/*)),--seed $(b)=boards/$(b)) --seed odb=odb --seed cadence=cadence

# Each board folder has a design.yaml and a PROVENANCE.md section, and no project.yaml sits over
# them. Name an agni to read every design too: make verify AGNI=agni. Without one the reads are
# skipped, since the default AGNI need not exist. `make test` checks verify itself the same way.
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
# Reports go to reports/, which git ignores. They carry every net name and reference designator, so
# only the intake and trial reports are meant to leave the machine.
#
# A target that would need logic beyond one agni command is a missing command or flag in agni, and is
# filed there rather than scripted here.
#
# These take a value from the make command line only, never from the environment. A shell that
# exports DESIGN for another project's Makefile would otherwise aim every target here at that design.
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

# A checklist walk. CHECKLIST is a manifest file, or the name of one the design's project declares.
review: | $(REPORTS)
	$(AGNI) review $(MOUNTS) $(DESIGN) --checklist $(CHECKLIST)
	$(AGNI) review $(MOUNTS) $(DESIGN) --checklist $(CHECKLIST) --format html -o $(REPORTS)/$(NAME)-review.html

# Two revisions, or two views of one board. RENAME_APPROX=1 also pairs nets renamed and changed.
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

# The vocabulary agni reads the design's names with, for the verify-lexicon skill.
lexicon:
	$(AGNI) lexicon $(MOUNTS) $(DESIGN)

# A row per pin the design's io_map declares, to sign off against the netlist and the datasheet.
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
# The diff compares Glasgow's schematic with its kicad-cli ODB++ export. The pin map is the one
# Glasgow's firmware drives, declared in its design.yaml.
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

# tutorial-board: schematics only, no board file. The docsite ladder never reads copper, and the
# Jetson board file is 81MB, so shipping it here would multiply every tutorial CI run by twenty.
$(DIST)/tutorial-board-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find boards/jetson-agx-thor-baseboard -type f ! -name '._*' \
	  \( -name '*.kicad_sch' -o -name '*.kicad_pro' -o -name 'LICENSE' -o -name 'README.md' \) \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# oracle-corpus: every board, both views. The KiCad reader cross-check reads a schematic and its
# board file and compares the two net sets, so it needs the copper half that the tutorial does not.
#
# A board's params/ ships here too, the datasheet facts its design.yaml names.
#
# The design.yaml descriptors ship here and NOT in tutorial-board. A descriptor names the board file
# as a companion, and agni fails a read whose declared companion is missing, so a descriptor in the
# schematics-only tarball would break every read of the tutorial board.
$(DIST)/oracle-corpus-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find boards -type f ! -name '._*' \
	  \( -name '*.kicad_sch' -o -name '*.kicad_pcb' -o -name '*.kicad_pro' -o -name '*.kicad_dru' \
	     -o -name '*.kicad_sym' -o -name '*.kicad_mod' -o -name '*-lib-table' \
	     -o -name 'design.yaml' -o -name '*.textproto' -o -name 'LICENSE' -o -name 'README.md' \) \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# odb-altium: ODB++ jobs another tool wrote, byte-identical to their publishers' (foxBMS's, written by
# Altium Designer). agni's gate reads them for the dialect KiCad's exporter never writes, so this one
# stays small enough to fetch on every CI run.
$(DIST)/odb-altium-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/altium -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# odb-kicad: each KiCad board above exported to ODB++ by kicad-cli (odb-kicad-jobs). agni reads a
# board both ways and requires the two to agree, which only makes sense beside oracle-corpus, so it
# ships apart from the gate's artifacts.
$(DIST)/odb-kicad-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/kicad -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# allegro: Allegro board files, byte-identical to their publishers', each beside an extract Allegro
# wrote from the same board. agni's Allegro reader is held to the extract, so the two ship together.
ALLEGRO_EXTRACT_BOARDS := allegro/beaglebone-ai
$(DIST)/allegro-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find $(ALLEGRO_EXTRACT_BOARDS) -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# allegro-boards: the other Allegro boards, one per .brd header family, with the files Allegro wrote
# beside them (Gerbers and drill, a placement report, the OrCAD schematic). No publisher released an
# extract for these, so a read of the .brd is checked against those instead. About 90MB, so it ships
# apart from allegro and a job that only needs the extract-backed board fetches less.
$(DIST)/allegro-boards-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find allegro -type f ! -name '._*' $(foreach b,$(ALLEGRO_EXTRACT_BOARDS),! -path '$(b)/*') \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

# cadence-exports: designs Cadence's tools wrote out in formats agni reads today, byte-identical to
# their publishers'. The ODB++ jobs Allegro wrote sit under odb/allegro/, beside odb/altium/, and the
# IPC-2581 and EDIF exports sit under cadence/ with a design.yaml each.
$(DIST)/cadence-exports-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find odb/allegro cadence -type f ! -name '._*' | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

dist: $(DIST)/tutorial-board-$(VERSION).tar.gz $(DIST)/oracle-corpus-$(VERSION).tar.gz \
      $(DIST)/odb-altium-$(VERSION).tar.gz $(DIST)/odb-kicad-$(VERSION).tar.gz \
      $(DIST)/allegro-$(VERSION).tar.gz $(DIST)/allegro-boards-$(VERSION).tar.gz \
      $(DIST)/cadence-exports-$(VERSION).tar.gz
	@cd $(DIST) && shasum -a 256 *-$(VERSION).tar.gz > SHA256SUMS
	@echo
	@echo "built $(VERSION):"
	@ls -lh $(DIST)/*-$(VERSION).tar.gz | awk '{printf "  %-46s %s\n", $$9, $$5}'
	@echo
	@cat $(DIST)/SHA256SUMS

# What the engine pins. Paste these two lines into its samples fetch target.
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
# nanometre. The exporter stamps the time it ran into two files of each job, and those stamps are
# fixed so a regeneration with no board change rewrites nothing that matters; the .kicad_prl it
# leaves beside a board with none is removed.
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
