#!/usr/bin/env bash
# Lint the agent-facing docs against the published artifacts.
# Catches drift: broken links, missing skill cards, stale checksums,
# latest copies out of sync with the highest versioned zip.
#
# Usage: bash tools/llms-check.sh [repo-root]
set -u
shopt -s nullglob

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
HOST="https://isandburn.github.io"

errors=0
err() {
  printf 'FAIL: %s\n' "$1"
  errors=$((errors + 1))
}

# --- link integrity ---------------------------------------------------------

checked_links=0
check_links() {
  local file="$1" target rel
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    target="${target%%#*}"
    [ -n "$target" ] || continue
    case "$target" in
      "$HOST"/*) rel="${target#"$HOST"/}" ;;
      /*)        rel="${target#/}" ;;
      *)         continue ;;
    esac
    rel="${rel%/}"
    [ -n "$rel" ] || continue
    if [ ! -e "$ROOT/$rel" ]; then
      err "$file: link target not found in repo: $target"
    fi
    checked_links=$((checked_links + 1))
  done < <(grep -oE '\]\([^)]+\)' "$ROOT/$file" | sed -e 's/^](//' -e 's/)$//')
}

for f in llms.txt skills.md code.md; do
  if [ -f "$ROOT/$f" ]; then
    check_links "$f"
  else
    err "required file missing: $f"
  fi
done
for f in "$ROOT"/skills/*.md; do
  [ -e "$f" ] || continue
  check_links "${f#"$ROOT"/}"
done

# --- skills -----------------------------------------------------------------

tuples=""
known_names=""
for zip in "$ROOT"/skills/*.zip; do
  base=$(basename "$zip")
  if [[ "$base" =~ ^(.+)-([0-9]+(\.[0-9]+)+)\.zip$ ]]; then
    name="${BASH_REMATCH[1]}"
    ver="${BASH_REMATCH[2]}"
    tuples+="$name $ver $zip"$'\n'
    known_names+="$name"$'\n'
  fi
done
known_names=$(printf '%s' "$known_names" | sort -u)

skill_report=""
while IFS= read -r name; do
  [ -n "$name" ] || continue

  latest_ver=$(printf '%s' "$tuples" | awk -v n="$name" '$1 == n { print $2 }' | sort -V | tail -n1)
  latest_zip="$ROOT/skills/$name-$latest_ver.zip"
  want_sha=$(sha256sum "$latest_zip" | awk '{ print $1 }')

  if [ ! -f "$ROOT/skills.md" ]; then
    err "skills.md missing; cannot verify skill '$name'"
    continue
  fi
  section=$(awk -v n="$name" '$0 == "## " n { found = 1; next } found && /^## / { exit } found { print }' "$ROOT/skills.md")
  if [ -z "$section" ]; then
    err "skills.md: missing '## $name' section for skill '$name'"
    continue
  fi

  if ! grep -Fq -e "- **Checksum:** sha256 $want_sha" <<<"$section"; then
    err "skills.md: '## $name' checksum does not match skills/$name-$latest_ver.zip"
  fi
  if ! grep -Fq "/skills/$name-$latest_ver.zip" <<<"$section"; then
    err "skills.md: '## $name' does not reference /skills/$name-$latest_ver.zip"
  fi

  if [ ! -f "$ROOT/skills/$name.md" ]; then
    err "skills/$name.md: card missing for published skill '$name'"
  fi

  latest_copy="$ROOT/skills/$name.zip"
  if [ ! -f "$latest_copy" ]; then
    err "skills/$name.zip: latest copy missing for skill '$name'"
  else
    have_sha=$(sha256sum "$latest_copy" | awk '{ print $1 }')
    if [ "$have_sha" != "$want_sha" ]; then
      err "skills/$name.zip: latest copy differs from skills/$name-$latest_ver.zip"
    fi
  fi

  skill_report+="$name@$latest_ver "
done <<< "$known_names"

# latest copies with no versioned zip
for zip in "$ROOT"/skills/*.zip; do
  base=$(basename "$zip")
  if [[ ! "$base" =~ ^(.+)-[0-9]+(\.[0-9]+)+\.zip$ ]]; then
    name="${base%.zip}"
    if ! grep -Fxq "$name" <<<"$known_names"; then
      err "skills/$base: latest copy without a versioned zip"
    fi
  fi
done

# cards with no published package (README.md is the maintainer doc, not a card)
for card in "$ROOT"/skills/*.md; do
  [ -e "$card" ] || continue
  name=$(basename "$card" .md)
  [ "$name" = "README" ] && continue
  if ! grep -Fxq "$name" <<<"$known_names"; then
    err "skills/$name.md: card for a skill with no published package"
  fi
done

# --- code -------------------------------------------------------------------

if [ -f "$ROOT/code.md" ] && [ -f "$ROOT/code_block_content.txt" ] && [ -f "$ROOT/llms.txt" ]; then
  if ! grep -q "code_block_content.txt" "$ROOT/code.md" && ! grep -q "code_block_content.txt" "$ROOT/llms.txt"; then
    err "code_block_content.txt not referenced by code.md or llms.txt"
  fi
fi

# --- llms.txt -----------------------------------------------------------------

if [ -f "$ROOT/llms.txt" ]; then
  if [ "$(head -n1 "$ROOT/llms.txt" | cut -c1-2)" != "# " ]; then
    err "llms.txt: must start with a '# ' heading"
  fi
fi

# --- summary ------------------------------------------------------------------

if [ "$errors" -gt 0 ]; then
  printf 'FAIL: %d error(s) in agent docs\n' "$errors"
  exit 1
fi

printf 'links OK (%d refs)\n' "$checked_links"
printf 'skills OK (%s)\n' "${skill_report% }"
printf 'code OK\n'
printf 'PASS\n'
