#!/bin/sh
f="$HOME/.config/sway/config.d/colors.conf"
[ -f "$f" ] || exit 0
swaymsg "$(grep '^client\.' "$f" | paste -sd ';')" > /dev/null
