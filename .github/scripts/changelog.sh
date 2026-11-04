#!/usr/bin/env bash
# Builds a changelog by comparing this tag with the previous release.
# Save as .github/scripts/changelog.sh in the repo.
# Usage: bash .github/scripts/changelog.sh v1.2.0 > changelog.md
#
# Full release (v1.2.0)       -> compared with the previous FULL release, so
#                                the notes cover the whole cycle, betas included.
# Pre-release (v1.2.0-beta.2) -> compared with the previous tag of any kind, so
#                                testers see only what changed since last build.
#
# Needs a full clone (fetch-depth: 0) so every tag is available.
set -euo pipefail

CUR="${1:?usage: changelog.sh TAG}"
LIMIT_FILES=15
LIMIT_COMMITS=20

case "${CUR#v}" in *-*) PRE=1 ;; *) PRE=0 ;; esac

PREV=""
if [ "$PRE" = 0 ]; then
  PREV=$(git describe --tags --abbrev=0 --match 'v*' --exclude 'v*-*' "${CUR}^" 2>/dev/null || true)
fi
if [ -z "$PREV" ]; then
  PREV=$(git describe --tags --abbrev=0 --match 'v*' "${CUR}^" 2>/dev/null || true)
fi

if [ -z "$PREV" ]; then
  echo "First tagged release."
  exit 0
fi

W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

show() { git show "$1:$2" 2>/dev/null || true; }

# Mod names from the CurseForge export's modlist.html, without the "(by Author)" part.
names() {
  grep -o '<a href="[^"]*">[^<]*</a>' \
    | sed -E 's/^.*">([^<]*)<\/a>$/\1/; s/ \(by [^)]*\)$//; s/&amp;/\&/g; s/&#39;/'"'"'/g' \
    | sort -u
}

show "$PREV" modlist.html | names > "$W/prev.names"
show "$CUR"  modlist.html | names > "$W/cur.names"

# projectID and fileID pairs from manifest.json, to count updated mods.
for side in prev cur; do
  ref=$PREV; [ "$side" = cur ] && ref=$CUR
  show "$ref" manifest.json \
    | jq -r '.files[]? | "\(.projectID)\t\(.fileID)"' 2>/dev/null \
    | sort -t$'\t' -k1,1 > "$W/$side.ids" || true
done

echo "Changes since ${PREV}"
echo

# ---- Mods ----
if [ -s "$W/prev.names" ] && [ -s "$W/cur.names" ]; then
  comm -13 "$W/prev.names" "$W/cur.names" > "$W/added"
  comm -23 "$W/prev.names" "$W/cur.names" > "$W/removed"
else
  : > "$W/added"; : > "$W/removed"
fi
UPDATED=$(join -t$'\t' -j1 "$W/prev.ids" "$W/cur.ids" | awk -F'\t' '$2 != $3' | wc -l | tr -d ' ')

if [ -s "$W/added" ] || [ -s "$W/removed" ] || [ "$UPDATED" -gt 0 ]; then
  echo "**Mods**"
  sed 's/^/- Added: /'   "$W/added"
  sed 's/^/- Removed: /' "$W/removed"
  [ "$UPDATED" -gt 0 ] && echo "- Updated: ${UPDATED} mod(s) to newer versions"
  echo
fi

# ---- Files inside overrides/ ----
git diff --name-status --no-renames "$PREV" "$CUR" -- overrides > "$W/files" || true
if [ -s "$W/files" ]; then
  awk -F'\t' '
    { s = ($1 == "A") ? "added" : ($1 == "D") ? "removed" : "changed"
      p = $2; sub(/^overrides\//, "", p)
      print s "\t" p }' "$W/files" > "$W/files.clean"

  grep -E $'\t(config|kubejs|defaultconfigs)/' "$W/files.clean" > "$W/f.cfg" || true
  grep -E $'\t(mods|shaderpacks|resourcepacks)/' "$W/files.clean" > "$W/f.bundled" || true

  emit() { # file, heading
    [ -s "$1" ] || return 0
    echo "**$2**"
    head -n "$LIMIT_FILES" "$1" | awk -F'\t' '{ printf "- %s (%s)\n", $2, $1 }'
    n=$(wc -l < "$1" | tr -d ' ')
    [ "$n" -gt "$LIMIT_FILES" ] && echo "- and $((n - LIMIT_FILES)) more"
    echo
  }
  emit "$W/f.cfg"     "Config and scripts"
  emit "$W/f.bundled" "Bundled files"
fi

# ---- Commit notes ----
git log --no-merges --pretty='- %s' "${PREV}..${CUR}" | head -n "$LIMIT_COMMITS" > "$W/commits" || true
if [ -s "$W/commits" ]; then
  echo "**Notes**"
  cat "$W/commits"
fi
