# shellcheck shell=bash
# direnv for Git Bash: source this file from ~/.bashrc. It is direnv's own
# hook (direnv hook bash) with the direnv in opt/ and PATH kept in Git Bash's
# form. Does nothing when no direnv is installed.
_direnv_hook_dir=${BASH_SOURCE[0]%/*}
[ "$_direnv_hook_dir" != "${BASH_SOURCE[0]}" ] || _direnv_hook_dir=.
# shellcheck source=utils/direnv_load.sh
source "$_direnv_hook_dir/utils/direnv_load.sh"
unset _direnv_hook_dir

if _direnv_exe=$(direnv_find); then
  _direnv_hook () {
    local previous_exit_status=$?
    local previous_sigint_trap
    previous_sigint_trap=$(trap -p SIGINT)
    trap -- '' SIGINT
    direnv_load "$_direnv_exe"
    eval "${previous_sigint_trap:-trap - SIGINT}"
    return $previous_exit_status
  }
  if [[ ";${PROMPT_COMMAND[*]:-};" != *";_direnv_hook;"* ]]; then
    if [[ "$(declare -p PROMPT_COMMAND 2>&1)" == "declare -a"* ]]; then
      PROMPT_COMMAND=(_direnv_hook "${PROMPT_COMMAND[@]}")
    else
      # shellcheck disable=SC2128,SC2178  # PROMPT_COMMAND is a string here
      PROMPT_COMMAND="_direnv_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
    fi
  fi
else
  unset _direnv_exe
fi
