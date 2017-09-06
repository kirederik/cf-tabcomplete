#!/usr/bin/env bash

rm "$HOME/.cf_complete_apps"

_complete_cf() {
  COMPREPLY=()
  local current_cmd="$1" # $1 is the command being completed
  local current_word="$2" # $2 is the word that is currently being completed
  local prev_arg="$3" # $3 is the previous word
  # For example: `cf apps myappname<TAB>`
  # $1 is `cf`; $2 is `myappname`; $3 is `apps`

  if [ "$current_cmd" != "cf" ]; then
    echo -en "\ncf-complete can only auto-complete cf commands; '$current_cmd' is not supported"
    return
  fi

  local completion=""

  case "$prev_arg" in
    "cf") completion="$(__cf_commands)" ;;
    "app") completion="$(__cf_apps)" ;;
  esac

  if [ -n "$completion" ]; then
    COMPREPLY=( $( compgen -W "$completion" -- "$current_word" ) )
  fi
}

__cf_commands() {
  cf help -a | \
    sed -e '1,/GETTING STARTED/d;/ENVIRONMENT VARIABLES/,$d' | \
    grep -E "^   " | \
    awk -v ORS=" " '{print $1}'
}

__cf_apps() {
  local apps_file
  apps_file="$HOME/.cf_complete_apps"
  if [ ! -f "$apps_file" ] && ! test "$(find "$apps_file" -mtime -60s 1>&2 2>/dev/null)"; then
    cf apps > "$apps_file"
  fi
  cat "$apps_file" | sed -e '1,/name/d' | awk -v ORS=" " '{print $1}'
}

complete -F _complete_cf -o bashdefault cf
