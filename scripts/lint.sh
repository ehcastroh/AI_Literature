#!/usr/bin/env bash
# Deterministic wiki lint. Run from anywhere inside the repo.
#
# Checks:
#   1. Dead wikilinks   -- [[slug]] with no wiki/**/*.md whose basename is <slug>.
#   2. Coverage         -- raw/papers/*.pdf count vs. wiki/wiki/*.md count.
#   3. Inventory drift  -- last "Inventory after: n/N" in wiki/log.md vs. filesystem.
#   4. Log coverage     -- every raw/papers/*.pdf must be named in wiki/log.md.
#
# Exits 0 on pass, 1 on any failure. Prints one section per check.
# wiki/CLAUDE.md is scanned for targets but not for link *sources* -- it contains
# template placeholders like [[slug]] and [[concept-slug]] that are not real links.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

FAIL=0
section() { printf '\n== %s ==\n' "$1"; }

section "Dead wikilinks"
# Collect referenced slugs, excluding wiki/CLAUDE.md (template placeholders).
REFS=$(find wiki -type f -name '*.md' ! -name 'CLAUDE.md' -print0 \
  | xargs -0 grep -hoE '\[\[[A-Za-z0-9._-]+\]\]' 2>/dev/null \
  | sed -E 's/^\[\[|\]\]$//g' | sort -u)

# Collect existing file basenames (any .md under wiki/, excluding wiki/raw/).
FILES=$(find wiki -type f -name '*.md' ! -path 'wiki/raw/*' -printf '%f\n' \
  | sed 's/\.md$//' | sort -u)

DEAD=$(comm -23 <(printf '%s\n' "$REFS") <(printf '%s\n' "$FILES"))
if [[ -n "$DEAD" ]]; then
  while IFS= read -r slug; do
    # Locate every source file that references the dead link.
    src=$(grep -rln "\[\[$slug\]\]" wiki --include='*.md' \
      --exclude='CLAUDE.md' | paste -sd, -)
    printf '  DEAD  [[%s]]  in: %s\n' "$slug" "$src"
  done <<< "$DEAD"
  FAIL=1
else
  echo "  ok"
fi

section "Coverage: raw/papers vs. wiki/wiki"
PDF_COUNT=$(find raw/papers -maxdepth 1 -name '*.pdf' | wc -l | tr -d ' ')
NOTE_COUNT=$(find wiki/wiki -maxdepth 1 -name '*.md' ! -name '.gitkeep' \
  | wc -l | tr -d ' ')
printf '  raw/papers: %s PDFs\n' "$PDF_COUNT"
printf '  wiki/wiki:  %s notes\n' "$NOTE_COUNT"
if [[ "$PDF_COUNT" -ne "$NOTE_COUNT" ]]; then
  printf '  MISMATCH: %s PDFs without a note\n' "$((PDF_COUNT - NOTE_COUNT))"
  FAIL=1
fi

section "Log inventory drift"
# Take the max denominator across all "Inventory after: X/Y" lines. This is
# order-independent: whether entries are appended or prepended, the highest Y
# ever recorded should equal the current PDF count.
CLAIMED_TOTAL=$(grep -oE 'Inventory after: [0-9]+/[0-9]+' wiki/log.md \
  | awk -F/ '{print $NF}' | sort -n | tail -1 || true)
if [[ -z "$CLAIMED_TOTAL" ]]; then
  echo "  no 'Inventory after:' line found in wiki/log.md"
  FAIL=1
else
  printf '  log max total: %s\n' "$CLAIMED_TOTAL"
  printf '  filesystem:    %s PDFs\n' "$PDF_COUNT"
  if [[ "$CLAIMED_TOTAL" != "$PDF_COUNT" ]]; then
    printf '  DRIFT: log max total (%s) != raw/papers total (%s)\n' \
      "$CLAIMED_TOTAL" "$PDF_COUNT"
    FAIL=1
  fi
fi

section "Log coverage: every PDF named in log"
MISSING=0
for pdf in raw/papers/*.pdf; do
  base=$(basename "$pdf")
  if ! grep -qF "$base" wiki/log.md; then
    printf '  MISSING: %s\n' "$base"
    MISSING=$((MISSING + 1))
    FAIL=1
  fi
done
[[ $MISSING -eq 0 ]] && echo "  ok"

echo
if [[ $FAIL -eq 0 ]]; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi
