#!/bin/sh

output=$1
style=$2
shift 2

pkill -x waybar
jq -r ".output = [\"$output\"]" $HOME/.config/waybar/config-base.json > $HOME/.config/waybar/config
waybar -s $HOME/.config/waybar/$style &
echo "restarted waybar"
