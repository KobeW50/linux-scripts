#!/usr/bin/env bash

# The battery percentage required for 'balanced' mode to be used when charging.
# This value should be lower than 'THRESHOLD_FOR_PERFORMANCE_MODE'.
# Set this to '0' to only use 'balanced' mode when charging until past 'THRESHOLD_FOR_PERFORMANCE_MODE'.
THRESHOLD_FOR_BALANCED_MODE=0

# The battery percentage required for 'performance' mode to be used when charging (if available).
# This value should be higher than 'THRESHOLD_FOR_BALANCED_MODE'. 
# Set this to '100' to only use 'balanced' mode when charging past 'THRESHOLD_FOR_BALANCED_MODE'.
THRESHOLD_FOR_PERFORMANCE_MODE=100

# Note that 'performance' mode is not available on all devices. Run 'powerprofilesctl list' to see the available modes for the device.
# If 'performance' mode is not available on the device, this script will (hopefully) only use 'balanced' and 'power-saving' mode without issues.

# How frequently, in seconds, this script should check if the charging/discharging state has changed.
SLEEP_INTERVAL=15


check_dependencies() {
    for dependency in powerprofilesctl upower grep awk; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            exit 1
        fi
    done
}


battery_threshold_met() {
    threshold="$1"
    battery_percentage=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | awk '/percentage:/ {print $2}')
    battery_percentage="${battery_percentage%\%}" # Remove trailing '%'

    if [ $battery_percentage -gt $threshold ]; then
        return 0
    else
        return 1
    fi
}


check_dependencies

powerprofilesctl list | grep -q "performance"
performance_mode_available=$?

ppd_mode=$(powerprofilesctl get)
last_used_mode="$ppd_mode"

# TODO: Prompt user with YAD if user changes charging state after manually changing mode

while [[ "$last_used_mode" == "$ppd_mode" ]]; do # Exit loop if mode is changed manually

    charging_state=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | awk '/state:/ {print $2}')

    if ([[ "$charging_state" == "discharging" ]] || ! battery_threshold_met "$THRESHOLD_FOR_BALANCED_MODE") &&
    [[ "$ppd_mode" != "power-saver" ]]; then

        powerprofilesctl set "power-saver"
        last_used_mode="power-saver"

    elif [[ "$charging_state" == "charging" && "$performance_mode_available" -eq 0 && "$ppd_mode" != "performance" ]] && 
    battery_threshold_met "$THRESHOLD_FOR_PERFORMANCE_MODE"; then

        powerprofilesctl set "performance"
        last_used_mode="performance"
    
    elif [[ "$charging_state" == "charging" && "$ppd_mode" != "balanced" ]] && battery_threshold_met "$THRESHOLD_FOR_BALANCED_MODE"; then

        powerprofilesctl set "balanced"
        last_used_mode="balanced"
    fi

    sleep $SLEEP_INTERVAL
    ppd_mode=$(powerprofilesctl get)
done