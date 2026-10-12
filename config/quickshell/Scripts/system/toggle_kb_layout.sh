#!/bin/bash

# Cycle every layout in input:kb_layout. They stay one group with US first,
# so keybinds keep resolving against US keysyms.
hyprctl switchxkblayout all next >/dev/null 2>&1 || exit 1

NAME=$(hyprctl devices -j 2>/dev/null | jq -r '(.keyboards | (map(select(.main == true))[0] // .[0])) | .active_keymap' 2>/dev/null)
notify-send -r 701 "Keyboard Layout" "Switched to ${NAME:-next layout}" 2>/dev/null || true
