#!/bin/sh

output_1=$1
output_2=$2
style=$3
shift 3

pkill -x waybar
jq -r ".[0].output = \"$output_1\" | .[1].output = \"$output_2\"" $HOME/.config/waybar/config-base-dual.json > $HOME/.config/waybar/config
waybar -s $HOME/.config/waybar/$style &
echo "restarted waybar"
