#!/usr/bin/env bash
# install.sh — add this repository to Vim and the shell, and create the data
# directories. Safe to run again; the managed block is replaced, not duplicated.
#
#   ./install.sh
#
# It only touches two files, both of which you can inspect afterwards:
#   ~/.vimrc   -> sources integrations/vim/planner.vim
#   ~/.bashrc  -> sources integrations/shell/planner.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIMRC="${HOME}/.vimrc"
BASHRC="${HOME}/.bashrc"
BEGIN_VIM='" >>> planner >>>'
END_VIM='" <<< planner <<<'
BEGIN_SH='# >>> planner >>>'
END_SH='# <<< planner <<<'

trim_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk 'NF { last = NR } { line[NR] = $0 } END { for (i = 1; i <= last; i++) print line[i] }' "$file" \
    > "${file}.planner.tmp"
  mv "${file}.planner.tmp" "$file"
}

replace_block() {
  local file="$1" begin="$2" end="$3"
  shift 3
  touch "$file"

  if grep -qF -- "$begin" "$file" && ! grep -qF -- "$end" "$file"; then
    printf 'install: start marker without end marker in %s; fix it manually.\n' "$file" >&2
    return 1
  fi

  if grep -qF -- "$begin" "$file"; then
    awk -v b="$begin" -v e="$end" '
      $0 == b { skip = 1; next }
      $0 == e { skip = 0; next }
      !skip { print }
    ' "$file" > "${file}.planner.tmp"
    mv "${file}.planner.tmp" "$file"
  fi

  trim_file "$file"
  {
    [[ -s "$file" ]] && printf '\n'
    printf '%s\n' "$begin"
    printf '%s\n' "$@"
    printf '%s\n' "$end"
  } >> "$file"
}

vim_source="source ${ROOT// /\\ }/integrations/vim/planner.vim"
shell_source="source \"${ROOT}/integrations/shell/planner.sh\""

replace_block "$VIMRC" "$BEGIN_VIM" "$END_VIM" "$vim_source"
replace_block "$BASHRC" "$BEGIN_SH" "$END_SH" "$shell_source"

"$ROOT/bin/plan" init

cat <<EOF

Installed.

  Vim:    $VIMRC now sources $ROOT/integrations/vim/planner.vim
  Shell:  $BASHRC now sources $ROOT/integrations/shell/planner.sh
  Planner: ${PLANNER_DIR:-$ROOT}

Open a new terminal (or run: source "$BASHRC") and start with:

  plan today

To remove the integrations, run: $ROOT/uninstall.sh
EOF
