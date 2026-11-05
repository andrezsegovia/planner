# planner.sh — shell integration
#
# Sourced by the block install.sh writes into ~/.bashrc. It finds the repo from
# this file's location, so the repository can be cloned anywhere.

if [ -n "${BASH_SOURCE[0]:-}" ]; then
  _planner_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd)"
  if [ -n "$_planner_root" ]; then
    case ":$PATH:" in
      *":$_planner_root/bin:"*) ;;
      *) PATH="$_planner_root/bin:$PATH"; export PATH ;;
    esac
  fi
  unset _planner_root
fi
