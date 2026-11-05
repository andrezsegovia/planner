#!/usr/bin/env bash
# uninstall.sh — remove the managed blocks from ~/.vimrc and ~/.bashrc.
# Your planner data is kept unless you ask to purge it.
#
#   ./uninstall.sh            remove integrations, keep data/
#   ./uninstall.sh --purge    also delete data/ (asks for confirmation)

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

if [[ ${1:-} == "--purge" ]]; then
  printf 'Delete %s/data permanently? [y/N] ' "$ROOT"
  read -r answer
  if [[ $answer == [yY]* ]]; then
    rm -rf "$ROOT/data"
    printf 'deleted %s/data\n' "$ROOT"
  else
    printf 'kept %s/data\n' "$ROOT"
  fi
else
  printf 'data kept in %s/data\n' "$ROOT"
fi
