#!/bin/sh

output=$1
extra=$2
first=$3
shift 2

for i in "$@"; do
  swaymsg "workspace $i output '$output', workspace $i, move workspace to output '$output'"
  if [[ ! -z "$extra" ]] then
    swaymsg "workspace $i, $extra"
  fi
done

swaymsg "workspace $first"
swaymsg 'workspace next'
swaymsg 'workspace prev'
