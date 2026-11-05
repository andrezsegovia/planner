#!/usr/bin/env bash
# uninstall.sh — remove the managed blocks from ~/.vimrc and ~/.bashrc.
# Your plans are files in this repository; this script never touches them.
#
#   ./uninstall.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

trim_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk 'NF { last = NR } { line[NR] = $0 } END { for (i = 1; i <= last; i++) print line[i] }' "$file" \
    > "${file}.planner.tmp"
  mv "${file}.planner.tmp" "$file"
}

remove_block() {
  local file="$1" begin="$2" end="$3"
  [[ -f "$file" ]] || return 0
  grep -qF -- "$begin" "$file" || return 0
  awk -v b="$begin" -v e="$end" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip { print }
  ' "$file" > "${file}.planner.tmp"
  mv "${file}.planner.tmp" "$file"
  trim_file "$file"
  printf 'removed planner block from %s\n' "$file"
}

remove_block "$HOME/.vimrc" '" >>> planner >>>' '" <<< planner <<<'
remove_block "$HOME/.bashrc" '# >>> planner >>>' '# <<< planner <<<'

printf 'your plans remain in %s\n' "$ROOT"
