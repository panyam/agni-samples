#!/usr/bin/env bash
# Builds small trees, each with one fault, and checks that hack/verify.sh rejects every one and passes
# the clean tree. With AGNI set it also checks the read half: a design that reads as zero components
# fails, and a real board passes.
set -uo pipefail

here=$(cd "$(dirname "$0")" && pwd)
repo=$(dirname "$here")
verify="$here/verify.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

# A tree with one well-formed board. The board's design.yaml names no entry file, so it is only fit
# for the structural checks; the AGNI cases below build their own.
clean_tree() {
  local t=$1
  mkdir -p "$t/boards/alpha" "$t/odb"
  printf 'name: alpha\nentry: alpha.kicad_sch\n' > "$t/boards/alpha/design.yaml"
  printf '# Provenance\n\n## alpha\n\nfrom somewhere\n' > "$t/PROVENANCE.md"
  printf 'mounts:\n  boards: boards\n  odb: odb\n' > "$t/agni.yaml"
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

t=$work/root-project; clean_tree "$t"; : > "$t/project.yaml"
expect fail "a project.yaml at the root" "$t"

t=$work/boards-project; clean_tree "$t"; : > "$t/boards/project.yaml"
expect fail "a project.yaml under boards/" "$t"

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

  t=$work/bad-odb; clean_tree "$t"; rm -r "$t/boards/alpha"; : > "$t/PROVENANCE.md"
  mkdir -p "$t/odb/kicad"; printf 'not a tarball' > "$t/odb/kicad/broken.odb.tgz"
  expect fail "an ODB++ job that does not read" "$t" "$AGNI"
else
  echo "skip the read cases (set AGNI to run them)"
fi

[ $failures -eq 0 ] || { echo "$failures case(s) failed"; exit 1; }
