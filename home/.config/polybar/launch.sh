#!/bin/bash

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done
sleep 1;

MONITOR=eDP1 polybar bar1 &
