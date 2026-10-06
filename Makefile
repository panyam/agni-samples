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

.PHONY: all dist clean list verify

all: dist

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
# The design.yaml descriptors ship here and NOT in tutorial-board. A descriptor names the board file
# as a companion, and agni fails a read whose declared companion is missing, so a descriptor in the
# schematics-only tarball would break every read of the tutorial board.
$(DIST)/oracle-corpus-$(VERSION).tar.gz:
	@mkdir -p $(DIST)
	find boards -type f ! -name '._*' \
	  \( -name '*.kicad_sch' -o -name '*.kicad_pcb' -o -name '*.kicad_pro' -o -name '*.kicad_dru' \
	     -o -name '*.kicad_sym' -o -name '*.kicad_mod' -o -name '*-lib-table' \
	     -o -name 'design.yaml' -o -name 'LICENSE' -o -name 'README.md' \) \
	  | sort | tar -cf - -T - $(TAR_IDS) | gzip -n -9 > $@

dist: $(DIST)/tutorial-board-$(VERSION).tar.gz $(DIST)/oracle-corpus-$(VERSION).tar.gz
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

verify:
	@cd $(DIST) && shasum -a 256 -c SHA256SUMS
	@for f in $(DIST)/*-$(VERSION).tar.gz; do \
	  if tar -tzf $$f | grep -q '\(^\|/\)\._'; then echo "$$f carries AppleDouble files"; exit 1; fi; \
	done

clean:
	rm -rf $(DIST)
