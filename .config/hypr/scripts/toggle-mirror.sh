#!/bin/bash

LAPTOP="eDP-1"

# Get all monitors from hyprctl
MONITORS=$(hyprctl monitors -j)

# Count total monitors - when mirroring, the mirrored monitor doesn't appear in the list
MONITOR_COUNT=$(echo "$MONITORS" | jq '. | length')

if [ "$MONITOR_COUNT" -eq 1 ]; then
    # Only 1 monitor visible - disable mirroring to restore the external monitor
    hyprctl reload
    notify-send "Mirror Toggle" "Mirroring disabled" -u normal
else
    # Not mirrored - find external monitor and enable mirroring
    EXTERNAL=$(echo "$MONITORS" | jq -r --arg laptop "$LAPTOP" '.[] | select(.name != $laptop) | .name' | head -n1)

    if [ -z "$EXTERNAL" ]; then
        notify-send "Mirror Toggle" "No external monitor detected" -u normal
        exit 1
    fi

    # Enable mirroring - external monitor mirrors laptop
    hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$LAPTOP"
    notify-send "Mirror Toggle" "Mirroring enabled: $EXTERNAL mirrors $LAPTOP" -u normal
fi
