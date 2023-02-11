#!/bin/sh

wpctl set-volume @DEFAULT_AUDIO_SINK@ $1

gt_100() {
  echo $1 '>' 1.00 | bc -l
}

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -c 9-)

if [ $(gt_100 $volume) == "1" ]; then
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%
fi

