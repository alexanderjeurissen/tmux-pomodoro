#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

_get_current_time_stamp() {
  echo "`python -c 'import time; print int(time.time())'`"
}

_display_progress() {

  local h_pomodoro_fg_color=`pomodoro_fg_color`
  local h_pomodoro_bg_color=`pomodoro_bg_color`
  local h_pomodoro_filled_glyph=`pomodoro_filled_glyph`
  local h_pomodoro_empty_glyph=`pomodoro_empty_glyph`
  local h_pomodoro_active_glyph=`pomodoro_active_glyph`

  local filled_glyph="#[fg=${h_pomodoro_fg_color:='green'}]#[bg=${h_pomodoro_bg_color:='blue'}]${h_pomodoro_filled_glyph:=█}#[fg=default]#[bg=default]"
  local empty_glyph="#[fg=${h_pomodoro_fg_color:='green'}]#[bg=${h_pomodoro_bg_color:='blue'}]${h_pomodoro_empty_glyph:= }#[fg=default]#[bg=default]"
  local active_glyph="#[fg=${h_pomodoro_fg_color:='green'}]#[bg=${h_pomodoro_bg_color:='blue'}]${h_pomodoro_active_glyph:=█}#[fg=default]#[bg=default]"

  local end_time="$(get_tmux_option "@pomodoro_end_at")"
  local current_time="$(_get_current_time_stamp)"
  local time_difference=$(( $end_time - $current_time ))
  local time_remaining="$(( $time_difference / 60))" # time remaining in minutes

  set_tmux_option "@pomodoro_time_remaining" "$time_remaining"

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
  local h_pomodoro_duration=`pomodoro_duration_helper`
  local pomodoro_duration="$(( ${h_pomodoro_duration:=25} * 60 ))"
  local end_time="$(( $current_time + $pomodoro_duration ))"

  set_tmux_option "@pomodoro_state" "active"
  set_tmux_option "@pomodoro_end_at" "$end_time"

  tmux refresh-client -S
}

pomodoro_stop() {
  local h_pomodoro_show_clock=`pomodoro_show_clock_helper`
  local pomodoro_show_clock="${h_pomodoro_show_clock:=0}"
  local time_remaining="$(get_tmux_option "@pomodoro_time_remaining")"

  tmux display-message "POMODORO stopped"
  set_tmux_option "@pomodoro_state" "inactive"
  set_tmux_option "@pomodoro_end_at" ""

  if (($time_remaining == 0)); then
    if [[ $pomodoro_show_clock = 'on_stop' ]]; then
      tmux clock
    fi
  fi

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
