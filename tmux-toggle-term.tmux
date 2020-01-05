#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  if [ -z $option_value ]; then
    echo $default_value
  else
    echo $option_value
  fi
}

readonly key="$(get_tmux_option "@toggle-term-key" "C-j")"

tmux bind-key -n "$key" run-shell "$CURRENT_DIR/scripts/tmux-toggle-term.sh"
