Tmux pomodoro
=================

Tmux plugin that enables starting and displaying a pomodoro in your tmux status line.


Introduces a new #{pomodoro_status} format.


![image](https://raw.githubusercontent.com/alexanderjeurissen/tmux-pomodoro/main/screenshots/screenshot.png)

### Usage

There are several configuration options, most of which should be intuitive


**Pomodoro Duration** is configurable. The statements are optional and default to a pomodoro of 25 minutes.

```
  set -g @pomodoro_duration 25
```

**Foreground and background colors** are configurable. The statements are optional and default to a green **foreground** and blue **background**.

```
  set -g @pomodoro_fg_color 'green'
  set -g @pomodoro_bg_color 'blue'
```

**The glyphs used in the progress bar** are configurable. The statements are optional and default to a full block unicode character for active / remaining segments and an empty space for segments of the pomodoro that have passed.

```
  set -g @pomodoro_filled_glyph '█'
  set -g @pomodoro_empty_glyph '▒'
  set -g @pomodoro_active_glyph '█'
```

**Showing the tmux clock when the pomodoro finishes** One of my favorite features is showing the tmux clock when the pomodoro is done. It forces me to take a break and acknowledge that I'm aware of the finished pomodoro before resumming work.
It's disabled by default, and can be enabled as follows:

```
  set -g @pomodoro_show_clock 'on_stop'
```

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'alexanderjeurissen/tmux-pomodoro'

Hit `prefix + I` to fetch the plugin and source it.

`#{pomodoro_status}` interpolation should now work.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/alexanderjeurissen/tmux-pomodoro ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/tmux_pomodoro.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

`#{pomodoro_status}` interpolation should now work.

### Requirements

This plugin uses python, and more specifically the `pytz` package to do the timezone magic, as such
having python 2.7 or python 3.0 installed is required for this plugin to work.

