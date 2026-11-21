# shellcheck shell=bash
# Sourced by direnv-hook.sh and by the Claude Code hook of cesium-workspace.
source "$(dirname "${BASH_SOURCE[0]}")/newest_opt.sh"

# direnv_find: print the direnv on PATH, else the newest in opt/; fail when
# there is none.
direnv_find () {
  local dir
  if type -P direnv; then return 0; fi
  dir=$(newest_opt direnv) && [ -x "$dir/direnv.exe" ] || return 1
  printf '%s\n' "$dir/direnv.exe"
}

# direnv_load <direnv>: load the environment of the .envrc that applies to the
# current directory into this shell.
direnv_load () {
  eval "$("$1" export bash)"
  # direnv for Windows writes PATH in Windows form; Git Bash needs its own
  case $PATH in
    *\;*) PATH=$(/usr/bin/cygpath -u -p "$PATH") ;;
  esac
}
