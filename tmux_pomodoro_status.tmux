#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pomodoro_status="#($CURRENT_DIR/scripts/tmux_pomodoro.sh)"
pomodoro_status_interpolation_string="\#{pomodoro_status}"

tmux bind-key p run-shell "$CURRENT_DIR/scripts/tmux_pomodoro.sh start"
tmux bind-key P run-shell "$CURRENT_DIR/scripts/tmux_pomodoro.sh stop"

source $CURRENT_DIR/scripts/helpers.sh

do_interpolation() {
  local string="$1"
  local interpolated="${string/$pomodoro_status_interpolation_string/$pomodoro_status}"
  echo "$interpolated"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}
main
