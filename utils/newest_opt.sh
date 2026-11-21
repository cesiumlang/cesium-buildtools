# shellcheck shell=bash
# Sourced by .envrc and direnv-hook.sh.
# Uses only what bash has built in: direnv runs .envrc files with whatever
# PATH its caller has, and a VS Code started from the Start menu has no
# dirname, sort or tail on it.

# version_newer <a> <b>: whether version a is newer than version b. The
# parts between dots are compared as numbers where both are numbers.
version_newer () {
  local -a a b
  local i x y
  IFS=. read -r -a a <<< "$1"
  IFS=. read -r -a b <<< "$2"
  for ((i = 0; i < ${#a[@]} || i < ${#b[@]}; i++)); do
    x=${a[i]:-0}
    y=${b[i]:-0}
    if [[ $x =~ ^[0-9]+$ && $y =~ ^[0-9]+$ ]]; then
      ((10#$x > 10#$y)) && return 0
      ((10#$x < 10#$y)) && return 1
    else
      [[ $x > $y ]] && return 0
      [[ $x < $y ]] && return 1
    fi
  done
  return 1
}

# newest_opt <name>: print opt/<name>-<version> of the newest version
# installed; print nothing and fail when none is.
newest_opt () {
  local here opt dir newest=
  here=${BASH_SOURCE[0]%/*}
  [ "$here" != "${BASH_SOURCE[0]}" ] || here=.
  opt=$(cd "$here/.." && pwd)/opt
  for dir in "$opt/$1"-*/; do
    [ -d "$dir" ] || continue
    dir=${dir%/}
    if [ -z "$newest" ] || version_newer "${dir##*/"$1"-}" "${newest##*/"$1"-}"; then
      newest=$dir
    fi
  done
  [ -n "$newest" ] || return 1
  printf '%s\n' "$newest"
}
