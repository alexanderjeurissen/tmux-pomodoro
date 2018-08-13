#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

_get_current_time_stamp() {
  echo "`python -c 'import time; print int(time.time())'`"
}

_display_progress() {
  local filled_glyph='#[fg=black]█#[fg=default]'
  local empty_glyph='#[fg=black]▒#[fg=default]'
  local active_glyph='#[fg=black]█#[fg=default]'

  local end_time="$(get_tmux_option "@pomodoro_end_at")"
  local current_time="$(_get_current_time_stamp)"
  local time_difference=$(( $end_time - $current_time ))
  local time_remaining="$(( $time_difference / 60))" # time remaining in minutes

  local divider=5

  local filled_segments=$(($time_remaining / $divider))
  local empty_segments=$(($divider-$filled_segments))
  local remainder=$(($time_remaining % $divider))

  if (($time_remaining == 0)); then
    pomodoro_stop
  else

    if (($remainder > 0)); then
      empty_segments=$(($empty_segments-1))
      active_segments="$active_glyph"
    fi

    filled_segments=`printf "%${filled_segments}s"`
    empty_segments=`printf "%${empty_segments}s"`
    echo "${filled_segments// /$filled_glyph}$active_segments${empty_segments// /$empty_glyph}" |
      sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
  fi
}

pomodoro_start() {
  tmux display-message "POMODORO started"
  local current_time=$(_get_current_time_stamp)
  local pomodoro_duration="$((25*60))" # duration is 25 minutes by default
  local end_time="$(( $current_time + $pomodoro_duration ))"

  set_tmux_option "@pomodoro_state" "active"
  set_tmux_option "@pomodoro_end_at" "$end_time"

  tmux refresh-client -S
}

pomodoro_stop() {
  tmux display-message "POMODORO stopped"
  set_tmux_option "@pomodoro_state" "inactive"
  set_tmux_option "@pomodoro_end_at" ""

  tmux refresh-client -S
}

pomodoro_status() {
  local pomodoro_state="$(get_tmux_option "@pomodoro_state")"

  if [[ $pomodoro_state = "active" ]]; then
    echo "$(_display_progress)"
  fi
}

initialize_pomodoro() {
  local action="$1"

  if [[ $action = "start" ]]; then
    pomodoro_start
  elif [[ $action = "stop" ]]; then
    pomodoro_stop
  else
    pomodoro_status
  fi
}

initialize_pomodoro "$1"
