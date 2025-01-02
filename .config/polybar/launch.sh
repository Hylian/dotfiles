#!/usr/bin/env bash

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

MONITOR=eDP1 polybar bar1 &
