#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

_get_current_time_stamp() {
  echo "`python -c 'import time; print int(time.time())'`"
}

_display_progress() {
  local filled_glyph=''
  local empty_glyph=''
  local active_glyph=''
  local block_duration=5 # duration in minutes per block

  local end_time="$(get_tmux_option "@pomodoro_end_at")"
  local current_time="$(_get_current_time_stamp)"
  echo "end_time: $end_time, current_time: $current_time"
  local time_remaining="$(( ( $end_time - $current_time )/(60*60) ))" # time remaining in minutes
  local zero=0

  echo "time_remaining: $time_remaining"
  if [[ $time_remaining -le $zero ]]; then
    echo "☕POMO !"
  else
    local filled_segments=$(($time_remaining / $block_duration))
    local empty_segments=$(($block_duration-$filled_segments))
    local remainder=$(($time_remaining % $block_duration))

    if [[ $remainder -gt $zero ]]; then
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
  echo "pomodoro started"
  local current_time=$(_get_current_time_stamp)
  local pomodoro_duration="$((25*60*60))" # duration is 25 minutes by default
  local end_time="$(( $current_time + $pomodoro_duration ))"

  set_tmux_option "@pomodoro_state" "active"
  set_tmux_option "@pomodoro_end_at" "$end_time"
}

pomodoro_stop() {
  echo "pomodoro stopped"
  set_tmux_option "@pomodoro_state" "inactive"
}

pomodoro_status() {
  echo "pomodoro status"
  local pomodoro_state="$(get_tmux_option "@pomodoro_state")"

  if [[ $pomodoro_state = "active" ]]; then
    echo "$(_display_progress)"
  elif [[ $pomodoro_state = "inactive" ]]; then
    echo "☕POMO !"
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
