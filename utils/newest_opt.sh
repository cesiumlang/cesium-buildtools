# shellcheck shell=bash
# Sourced by .envrc and direnv-hook.sh.
# newest_opt <name>: print opt/<name>-<version> of the newest version
# installed; print nothing and fail when none is.
newest_opt () {
  local opt newest
  opt=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/opt
  newest=$(printf '%s\n' "$opt/$1"-*/ | sort -V | tail -n 1)
  [ -d "$newest" ] || return 1
  printf '%s\n' "${newest%/}"
}
