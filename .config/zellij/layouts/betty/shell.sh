#!/usr/bin/sh
while true; do
  adb -s product:betty root &> /dev/null && adb -s product:betty shell $*;
done
