#!/bin/sh

if cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor | grep 'powersave' then
  :
