#!/usr/bin/env bash

MAIN_PANE_TITLE="<Main Pane>"
CONTROL_PANE_TITLE="<Control Pane>"
ESCAPED_MAIN_PANE_TITLE="$MAIN_PANE_TITLE"
ESCAPED_CONTROL_PANE_TITLE="$CONTROL_PANE_TITLE"

from=""
key="C-j"

# `split-window` start directory
dir=""
split_direction="-v"
split_percentage="50"

curr_pane_title="$(tmux display-message -p "#{pane_title}")"
curr_pane_id="$(tmux display-message -p "#{pane_id}")"

escape() {
  echo $1 | sed 's/[]\/$*\.^[]/\\&/g'
}

is_vim() {
  ps -o state= -o comm= -t "$(tmux display-message -p '#{pane_tty}')" \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'
}

open_control_pane() {
  local control_pane_id="$(tmux list-panes -F '#D #T' | sed -n "s/^\(.*\) $ESCAPED_CONTROL_PANE_TITLE$/\1/p")"
  if [[ -n "$control_pane_id" ]]; then
    tmux select-pane -t "$control_pane_id"
  else
    tmux split-window "$split_direction" -c "$dir" -p "$split_percentage" \; \
      select-pane -T "$CONTROL_PANE_TITLE"
  fi
}

hidden_control_pane() {
  local main_pane_id="$(tmux list-panes -F '#D #T' | sed -n "s/^\(.*\) $ESCAPED_MAIN_PANE_TITLE$/\1/p")"
  if [[ -n "$main_pane_id" ]]; then
    tmux select-pane -t "$main_pane_id" \; resize-pane -Z

  else
    main_pane_id="$(tmux list-panes -F '#D #T' | grep -v "$ESCAPED_CONTROL_PANE_TITLE$" | grep -o '\d\+' | sort -n | head -n 1)"

    if [[ -n "$main_pane_id" ]]; then
      tmux select-pane -T "$MAIN_PANE_TITLE" -t "%$main_pane_id" \; \
        select-pane -t "%$main_pane_id" \; \
        resize-pane -Z
    else
      tmux split-window "$split_direction" -b -p "$((100 - $split_percentage))" \; \
        select-pane -T "$MAIN_PANE_TITLE" \; \
        resize-pane -Z
    fi

  fi
}

toggle_control_pane() {
  if [[ "$curr_pane_title" == "$MAIN_PANE_TITLE" ]]; then
    open_control_pane
  elif [[ "$curr_pane_title" == "$CONTROL_PANE_TITLE" ]]; then
    hidden_control_pane
  elif tmux list-panes -F '#T' | grep -q "^$ESCAPED_MAIN_PANE_TITLE$"; then
    open_control_pane
  else
    tmux select-pane -T "$MAIN_PANE_TITLE"
    open_control_pane
  fi
}

while [[ $# > 0 ]]; do
  case "$1" in
    --main-title)
      MAIN_PANE_TITLE="${2}"
      ESCAPED_MAIN_PANE_TITLE="$(escape "$MAIN_PANE_TITLE")"
      shift
      ;;
    --control-title)
      CONTROL_PANE_TITLE="${2}"
      ESCAPED_CONTROL_PANE_TITLE="$(escape "$CONTROL_PANE_TITLE")"
      shift
      ;;
    --from)
      from="${2}"
      shift
      ;;
    --key)
      key="${2}"
      shift
      ;;
    --dir)
      dir="${2}"
      shift
      ;;
    -v)
      split_direction="-v"
      ;;
    -h)
      split_direction="-h"
      ;;
    -p)
      split_percentage="${2}"
      shift
      ;;
  esac
  shift
done

if is_vim && [[ $from != "vim" ]]; then
  tmux send-keys "$key"
else
  toggle_control_pane
fi

