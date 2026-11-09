#!/usr/bin/env bash
# Checks the tree a checkout serves: hack/verify.sh [root]. If AGNI names an agni binary, it also
# reads every design through the root agni.yaml.
#
# Each folder under boards/ needs a design.yaml and its own "## <folder>" section in PROVENANCE.md.
# The folders under allegro/, odb/allegro/ and cadence/ have their own rules, below. Neither the
# root nor boards/ may hold a project.yaml. agni fails to load a design that sits under a
# project.yaml without naming it in `extends`, so a project.yaml there would break every board at
# once.
#
# A read must exit 0 and find at least one component. An agni too old for a board's format reads it
# as an empty design and still exits 0, and the viewer then shows an empty page.
set -uo pipefail

cd "${1:-.}" || exit 1
fail=0
bad() { echo "verify: $*" >&2; fail=1; }
# Picks the line of agni's output that says why a read failed: its first error, else its last line.
why() { printf '%s\n' "$1" | grep -m1 '^error' || printf '%s\n' "$1" | tail -1; }

for d in boards/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  [ -f "$d/design.yaml" ] || bad "boards/$name has no design.yaml"
  grep -qxF "## $name" PROVENANCE.md 2>/dev/null || bad "boards/$name has no '## $name' section in PROVENANCE.md"
done

# Each Allegro board, Allegro ODB++ job and Cadence export needs the publisher's licence beside it
# and a PROVENANCE.md heading naming its folder. A Cadence export also needs a design.yaml, since
# agni reads it as a design. An Allegro folder needs none, since agni reads a .brd by its name.
# One that also holds the Capture schematic has a design.yaml naming it, and is read as a design.
for d in allegro/*/ odb/allegro/*/ cadence/*/; do
  [ -d "$d" ] || continue
  dir=${d%/}
  [ -f "$dir/LICENSE" ] || bad "$dir has no LICENSE"
  grep -qE "^#+ .*\(\`$dir/\`\)" PROVENANCE.md 2>/dev/null || bad "$dir has no PROVENANCE.md heading naming (\`$dir/\`)"
  case $dir in cadence/*) [ -f "$dir/design.yaml" ] || bad "$dir has no design.yaml" ;; esac
done

# A board fetched from upstream has no LICENSE to ship, since none grants redistribution. It needs a
# line in remote/remote.pin and a PROVENANCE.md heading naming its folder, which says so. Its files
# must never be tracked, and .gitignore keeps them out. This checks the index too, so a forced add
# fails before it is pushed.
pinned=
if [ -f remote/remote.pin ]; then
  pinned=$(awk '$1 !~ /^#/ && NF >= 3 {print $2}' remote/remote.pin | sort -u)
  [ -n "$pinned" ] || bad "remote/remote.pin names no boards"
fi
for b in $pinned; do
  grep -qE "^#+ .*\(\`remote/$b/\`\)" PROVENANCE.md 2>/dev/null || bad "remote/$b has no PROVENANCE.md heading naming (\`remote/$b/\`)"
done
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r f; do
    [ "$f" = remote/remote.pin ] || bad "$f is tracked, and remote/ boards are fetched, never shipped (remote/remote.pin)"
  done < <(git ls-files -- remote)
fi

for p in project.yaml boards/project.yaml; do
  [ -e "$p" ] && bad "$p would become the project of every board, and no board extends it"
done

# A team's house boards must not reach this public repo. Only the README and the template are
# tracked under house/. No tracked file may name a mount beyond the four agni.yaml declares. A file
# that names mount://<team-folder> points into a team's own boards, and is about to be pushed. Both
# checks read git's index, so they also see what is staged. The pre-commit hook relies on that.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r f; do
    case $f in
      house/README.md | house/_template/*) ;;
      *) bad "$f is tracked, and house/ is for boards that stay on this machine (house/README.md)" ;;
    esac
  done < <(git ls-files -- house)

  while IFS= read -r hit; do
    bad "$hit names a mount other than boards, odb, cadence, allegro, altium, remote or house"
  done < <(git ls-files -z | xargs -0 grep -IHnoE 'mount://[A-Za-z0-9][A-Za-z0-9_.-]*' 2>/dev/null \
             | grep -vE ':mount://(boards|odb|cadence|allegro|altium|remote|house)$')
fi

if [ -n "${AGNI:-}" ]; then
  # house/ is read too, so a team's own boards get the same check. When HOUSE_DIR moves it, every
  # read names all seven mounts, because one --mount replaces agni.yaml's whole table.
  house=${HOUSE_DIR:-house}
  mounts=()
  [ "$house" = house ] || mounts=(--mount boards=boards --mount odb=odb --mount cadence=cadence --mount allegro=allegro --mount altium=altium --mount remote=remote --mount "house=$house")
  designs=$(find boards cadence allegro -name design.yaml ! -path '*/._*' -exec dirname {} \; 2>/dev/null | sort)
  house_designs=$(find "$house" -name design.yaml ! -path '*/._*' ! -path '*/_template/*' -exec dirname {} \; 2>/dev/null | sort)
  jobs=$(find odb -type f \( -name '*.odb.tgz' -o -name '*.odb.zip' \) ! -name '._*' 2>/dev/null | sort)
  # A native board is read by its own name. pc069, BeaglePlay, BeagleV-Fire, SLUGS v2, Parallella-I
  # and the ADALM1000 were saved by Allegro releases agni does not read yet (agni issue 1355), and
  # agni reads no ASCII .PcbDoc yet (agni issue 1393), so they are left out until it does.
  natives=$(find altium -name '*.PcbDoc' ! -name '._*' ! -path 'altium/osp-*/Outputs/*' 2>/dev/null
            find allegro -name '*.brd' ! -name '._*' ! -path 'allegro/pc069/*' ! -path 'allegro/beagleplay/*' \
              ! -path 'allegro/beaglev-fire/*' ! -path 'allegro/slugs-v2/*' ! -path 'allegro/parallella/*' \
              ! -path 'allegro/adalm1000/*' 2>/dev/null)
  # A fetched board is read when it has been fetched (make remote). The two BeagleBone boards are
  # Allegro 16.4, which agni does not read yet (agni issue 1355).
  natives="$natives
$(find remote -name '*.brd' ! -name '._*' ! -path 'remote/beaglebone-revc2/*' ! -path 'remote/beaglebone-black-revb4/*' 2>/dev/null)"
  natives=$(printf '%s\n' "$natives" | sed '/^$/d' | sort)
  uris=$(for p in $designs $jobs $natives; do echo "mount://$p"; done
         for p in $house_designs; do echo "mount://house/${p#"$house"/}"; done)
  for uri in $uris; do
    if ! out=$("$AGNI" stats ${mounts[@]+"${mounts[@]}"} "$uri" 2>&1); then
      bad "$uri does not read: $(why "$out")"
      continue
    fi
    n=$(printf '%s\n' "$out" | awk '/^components:/ {print $2}')
    if [ "${n:-0}" -eq 0 ]; then
      bad "$uri reads as zero components; $("$AGNI" version | head -1) may be too old for it"
      continue
    fi
    if ! out=$("$AGNI" check ${mounts[@]+"${mounts[@]}"} "$uri" 2>&1 >/dev/null); then
      bad "agni check $uri failed: $(why "$out")"
      continue
    fi
    echo "read $uri: $n components"
  done
fi

exit $fail
