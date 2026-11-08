#!/usr/bin/env bash
# Builds small trees, each with one fault, and checks that hack/verify.sh rejects every one and passes
# the clean tree. With AGNI set it also checks the reads. A design that reads as zero components
# fails, and a real board passes.
set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
repo=$(dirname "$here")
verify="$here/verify.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

# A tree with one well-formed board. The board's design.yaml names an entry file that doesn't exist,
# so the tree only suits the structural checks. The AGNI cases below build their own.
clean_tree() {
  local t=$1
  mkdir -p "$t/boards/alpha" "$t/odb"
  printf 'name: alpha\nentry: alpha.kicad_sch\n' > "$t/boards/alpha/design.yaml"
  printf '# Provenance\n\n## alpha\n\nfrom somewhere\n' > "$t/PROVENANCE.md"
  printf 'mounts:\n  boards: boards\n  odb: odb\n  cadence: cadence\n  house: house\n' > "$t/agni.yaml"
  mkdir -p "$t/cadence"
  mkdir -p "$t/house/_template"
  printf 'house\n' > "$t/house/README.md"
  printf 'name: house\n' > "$t/house/_template/project.yaml.example"
  git -C "$t" init -q && git -C "$t" add -A
}

# Spelled in two halves, so this file names no foreign mount itself and passes the check it tests.
foreign="mount:""//acme"


expect() {
  local want=$1 name=$2 tree=$3 out
  out=$(AGNI="${4:-}" "$verify" "$tree" 2>&1)
  local got=$?
  if { [ "$want" = pass ] && [ $got -ne 0 ]; } || { [ "$want" = fail ] && [ $got -eq 0 ]; }; then
    echo "FAIL $name: wanted $want, verify exited $got"
    printf '%s\n' "$out" | sed 's/^/    /'
    failures=$((failures + 1))
  else
    echo "ok   $name"
  fi
}

t=$work/clean; clean_tree "$t"
expect pass "a clean tree passes" "$t"

t=$work/no-descriptor; clean_tree "$t"; rm "$t/boards/alpha/design.yaml"
expect fail "a board with no design.yaml" "$t"

t=$work/no-provenance; clean_tree "$t"; printf '# Provenance\n\n## beta\n' > "$t/PROVENANCE.md"
expect fail "a board with no PROVENANCE.md section" "$t"

t=$work/prefix-provenance; clean_tree "$t"; printf '# Provenance\n\n## alpha-two\n' > "$t/PROVENANCE.md"
expect fail "a PROVENANCE.md section for a different board sharing the prefix" "$t"

remote_tree() {
  clean_tree "$1"
  mkdir -p "$1/remote"
  printf '%s  gadget  https://example.invalid/gadget.zip  unzip\n' "$(printf 'a%.0s' {1..64})" > "$1/remote/remote.pin"
  printf '\n### Gadget (`remote/gadget/`)\n\nno licence stated\n' >> "$1/PROVENANCE.md"
  git -C "$1" add -A
}

t=$work/remote; remote_tree "$t"
expect pass "a pinned remote board with its PROVENANCE.md heading" "$t"

t=$work/remote-no-provenance; remote_tree "$t"; printf '# Provenance\n\n## alpha\n' > "$t/PROVENANCE.md"
expect fail "a pinned remote board with no PROVENANCE.md heading" "$t"

t=$work/remote-tracked; remote_tree "$t"; mkdir -p "$t/remote/gadget"; : > "$t/remote/gadget/gadget.brd"
git -C "$t" add -f remote/gadget/gadget.brd
expect fail "a fetched remote board that is tracked" "$t"

t=$work/remote-empty-pin; remote_tree "$t"; printf '# nothing pinned\n' > "$t/remote/remote.pin"
expect fail "a remote.pin that names no boards" "$t"

t=$work/root-project; clean_tree "$t"; : > "$t/project.yaml"
expect fail "a project.yaml at the root" "$t"

t=$work/boards-project; clean_tree "$t"; : > "$t/boards/project.yaml"
expect fail "a project.yaml under boards/" "$t"

allegro_tree() {
  clean_tree "$1"; mkdir -p "$1/allegro/widget"
  : > "$1/allegro/widget/widget.brd"; printf 'CC-BY-4.0\n' > "$1/allegro/widget/LICENSE"
  printf '\n### Widget (`allegro/widget/`)\n' >> "$1/PROVENANCE.md"
}

t=$work/allegro-clean; allegro_tree "$t"
expect pass "an Allegro board with a licence and a section" "$t"

t=$work/allegro-no-licence; allegro_tree "$t"; rm "$t/allegro/widget/LICENSE"
expect fail "an Allegro board with no LICENSE" "$t"

t=$work/allegro-no-provenance; allegro_tree "$t"; printf '# Provenance\n\n## alpha\n' > "$t/PROVENANCE.md"
expect fail "an Allegro board with no PROVENANCE.md section" "$t"

cadence_tree() {
  clean_tree "$1"; mkdir -p "$1/cadence/gizmo" "$1/odb/allegro/gadget"
  printf 'name: gizmo\nentry: gizmo.edf\n' > "$1/cadence/gizmo/design.yaml"
  printf 'MIT\n' > "$1/cadence/gizmo/LICENSE"; printf 'MIT\n' > "$1/odb/allegro/gadget/LICENSE"
  printf '\n### Gizmo (`cadence/gizmo/`)\n\n### Gadget (`odb/allegro/gadget/`)\n' >> "$1/PROVENANCE.md"
}

t=$work/cadence-clean; cadence_tree "$t"
expect pass "a Cadence export and an Allegro ODB++ job with licences and sections" "$t"

t=$work/cadence-no-descriptor; cadence_tree "$t"; rm "$t/cadence/gizmo/design.yaml"
expect fail "a Cadence export with no design.yaml" "$t"

t=$work/cadence-no-provenance; cadence_tree "$t"; printf '# Provenance\n\n## alpha\n' > "$t/PROVENANCE.md"
expect fail "a Cadence export with no PROVENANCE.md section" "$t"

t=$work/allegro-odb-no-licence; cadence_tree "$t"; rm "$t/odb/allegro/gadget/LICENSE"
expect fail "an Allegro ODB++ job with no LICENSE" "$t"

t=$work/cadence-mount; cadence_tree "$t"
printf 'mount://cadence/gizmo\n' > "$t/notes.md"; git -C "$t" add notes.md
expect pass "a tracked file naming the cadence mount" "$t"

t=$work/house-board; clean_tree "$t"; mkdir -p "$t/house/widget"
printf 'name: widget\n' > "$t/house/widget/design.yaml"; git -C "$t" add -f house/widget/design.yaml
expect fail "a tracked file under house/" "$t"

t=$work/house-untracked; clean_tree "$t"; mkdir -p "$t/house/widget"
printf 'name: widget\n' > "$t/house/widget/design.yaml"
expect pass "an untracked house board" "$t"

t=$work/foreign-mount; clean_tree "$t"; printf 'see %s/widget\n' "$foreign" > "$t/notes.md"; git -C "$t" add notes.md
expect fail "a tracked file naming a mount other than boards, odb or house" "$t"

t=$work/known-mounts; clean_tree "$t"
printf 'mount://boards/alpha mount://odb/x mount://house/y\n' > "$t/notes.md"; git -C "$t" add notes.md
expect pass "a tracked file naming the three known mounts" "$t"

t=$work/placeholder-mount; clean_tree "$t"
printf 'DESIGN=mount://... or mount://<board>\n' > "$t/notes.md"; git -C "$t" add notes.md
expect pass "a placeholder mount in prose" "$t"

if [ -n "${AGNI:-}" ]; then
  t=$work/real; clean_tree "$t"; rm -r "$t/boards/alpha"
  cp -R "$repo/boards/glasgow-revC3" "$t/boards/"
  printf '# Provenance\n\n## glasgow-revC3\n' > "$t/PROVENANCE.md"
  expect pass "a real board reads" "$t" "$AGNI"

  t=$work/empty-read; clean_tree "$t"
  printf '(kicad_sch (version 20231120) (generator "eeschema") (uuid "00000000-0000-0000-0000-000000000000") (paper "A4"))\n' \
    > "$t/boards/alpha/alpha.kicad_sch"
  expect fail "a design that reads as zero components" "$t" "$AGNI"

  t=$work/house-read; clean_tree "$t"; rm -r "$t/boards/alpha"; cp -R "$repo/boards/glasgow-revC3" "$t/house/acme-io"
  expect pass "a house board reads" "$t" "$AGNI"

  t=$work/house-empty; clean_tree "$t"; rm -r "$t/boards/alpha"; mkdir -p "$t/house/widget"
  printf 'name: widget\nentry: widget.kicad_sch\n' > "$t/house/widget/design.yaml"
  printf '(kicad_sch (version 20231120) (generator "eeschema") (uuid "00000000-0000-0000-0000-000000000000") (paper "A4"))\n' \
    > "$t/house/widget/widget.kicad_sch"
  expect fail "a house board that reads as zero components" "$t" "$AGNI"

  t=$work/house-elsewhere; clean_tree "$t"; rm -r "$t/boards/alpha"; mkdir -p "$work/elsewhere/widget"
  printf 'name: widget\nentry: widget.kicad_sch\n' > "$work/elsewhere/widget/design.yaml"
  printf '(kicad_sch (version 20231120) (generator "eeschema") (uuid "00000000-0000-0000-0000-000000000000") (paper "A4"))\n' \
    > "$work/elsewhere/widget/widget.kicad_sch"
  HOUSE_DIR=$work/elsewhere expect fail "a house board in HOUSE_DIR that reads as zero components" "$t" "$AGNI"

  t=$work/cadence-read; cadence_tree "$t"; rm -r "$t/boards/alpha"
  cp "$repo/cadence/clay-r6/CLAYR6.EDF" "$t/cadence/gizmo/gizmo.edf"
  expect pass "a Cadence export reads" "$t" "$AGNI"

  t=$work/cadence-empty; cadence_tree "$t"; rm -r "$t/boards/alpha"
  printf '(edif empty (edifVersion 2 0 0) (edifLevel 0) (keywordMap (keywordLevel 0)))\n' > "$t/cadence/gizmo/gizmo.edf"
  expect fail "a Cadence export that reads as zero components" "$t" "$AGNI"

  t=$work/bad-odb; clean_tree "$t"; rm -r "$t/boards/alpha"; : > "$t/PROVENANCE.md"
  mkdir -p "$t/odb/kicad"; printf 'not a tarball' > "$t/odb/kicad/broken.odb.tgz"
  expect fail "an ODB++ job that does not read" "$t" "$AGNI"
else
  echo "skip the read cases (set AGNI to run them)"
fi

[ $failures -eq 0 ] || { echo "$failures case(s) failed"; exit 1; }
