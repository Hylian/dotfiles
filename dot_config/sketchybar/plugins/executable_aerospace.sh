#!/usr/bin/env bash

# Requires brew bash and flock

TEXT_ACTIVE=0xffd3c6aa
TEXT_INACTIVE=0x8fd3c6aa
TEXT_INACTIVE_EMPTY=0x3fd3c6aa
BG_ACTIVE=0xa03c4841
BG_INACTIVE=0x603c4841
BG_INACTIVE_EMPTY=0x303c4841

lockfile="/tmp/sketchybar_lock"
exec {fd}>$lockfile
flock --timeout 2 "$fd" || exit 1

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME label.color="$TEXT_ACTIVE" background.color="$BG_ACTIVE"
elif [ $(aerospace list-windows --workspace "$1" --count) -gt 0 ]; then
    sketchybar --set $NAME label.color="$TEXT_INACTIVE" background.color="$BG_INACTIVE"
else
    sketchybar --set $NAME label.color="$TEXT_INACTIVE_EMPTY" background.color="$BG_INACTIVE_EMPTY"
fi

exit 0
