#!/bin/dash

# Get CPU usage percentage and convert to float between 0 and 1
CPU_USAGE=$(top -l 1 | grep -E "^CPU" | tail -1 | awk '{ print ($3 + $5)/100 }')

# Update the graph with the new value
sketchybar --push "$NAME" "$CPU_USAGE"
