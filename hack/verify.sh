#!/usr/bin/env bash
# Checks the tree a checkout serves: hack/verify.sh [root]. With AGNI naming an agni binary, it also
# reads every design through the root agni.yaml.
#
# Each folder under boards/ needs a design.yaml and its own "## <folder>" section in PROVENANCE.md.
# Neither the root nor boards/ may hold a project.yaml: a design under one that does not `extends`
# it fails to load, so a project.yaml there would break every board at once.
#
# A read must find at least one component, as well as exit 0. An agni too old for a board's format
# reads it as an empty design and exits 0, and the viewer then shows an empty page.
set -uo pipefail

cd "${1:-.}" || exit 1
fail=0
bad() { echo "verify: $*" >&2; fail=1; }
# The line of agni's output that says why a read failed: its first error, else its last line.
why() { printf '%s\n' "$1" | grep -m1 '^error' || printf '%s\n' "$1" | tail -1; }

for d in boards/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  [ -f "$d/design.yaml" ] || bad "boards/$name has no design.yaml"
  grep -qxF "## $name" PROVENANCE.md 2>/dev/null || bad "boards/$name has no '## $name' section in PROVENANCE.md"
done

for p in project.yaml boards/project.yaml; do
  [ -e "$p" ] && bad "$p would become the project of every board, and no board extends it"
done

if [ -n "${AGNI:-}" ]; then
  designs=$(find boards -name design.yaml ! -path '*/._*' -exec dirname {} \; 2>/dev/null | sort)
  jobs=$(find odb -type f \( -name '*.odb.tgz' -o -name '*.odb.zip' \) ! -name '._*' 2>/dev/null | sort)
  for path in $designs $jobs; do
    uri=mount://$path
    if ! out=$("$AGNI" stats "$uri" 2>&1); then
      bad "$uri does not read: $(why "$out")"
      continue
    fi
    n=$(printf '%s\n' "$out" | awk '/^components:/ {print $2}')
    if [ "${n:-0}" -eq 0 ]; then
      bad "$uri reads as zero components; $("$AGNI" version | head -1) may be too old for it"
      continue
    fi
    if ! out=$("$AGNI" check "$uri" 2>&1 >/dev/null); then
      bad "agni check $uri failed: $(why "$out")"
      continue
    fi
    echo "read $uri: $n components"
  done
fi

exit $fail
