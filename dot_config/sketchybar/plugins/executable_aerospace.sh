#!/bin/dash

#sketchybar --set spaceid label="$FOCUSED_WORKSPACE"

#BG_GREEN=0xff3c4841
#BG_YELLOW=0xff45443c
#BG_BLUE=0xff384b55

#if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
#    sketchybar --set $NAME background.color="$BG_GREEN"
#else
#    sketchybar --set $NAME background.color="$BG_YELLOW"
#fi

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi
