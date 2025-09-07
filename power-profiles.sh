#!/usr/bin/env bash

# Run 'powerprofilesctl list' to see the available modes. Note that 'performance' mode is not available on all devices.
# If 'performance' mode is not available on your device, WORST_MODE will be 'power-saver' and BEST_MODE will be 'balanced'.

# The mode to use when charging and the battery percentage is higher than THRESHOLD_FOR_BEST_MODE.
# Can be 'performance' or 'balanced'
BEST_MODE="performance"

# The mode to use when discharging or when the battery percentage is lower than THRESHOLD_FOR_BEST_MODE.
# Can be 'power-saver' or 'balanced'
WORST_MODE="power-saver"

# The battery percentage required for BEST_MODE to be used when charging. Set to '0' to disable this feature.
THRESHOLD_FOR_BEST_MODE=20

# How frequently, in seconds, the script should check if the charging/discharging state has changed.
SLEEP_INTERVAL=15


check_dependencies() {
    for dependency in powerprofilesctl upower grep awk; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            exit 1
        fi
    done
}


# If 'performance' mode isn't available, fallback to using 'balanced' and 'power-saver'
check_power_modes() {
    if ! powerprofilesctl list | grep -q $BEST_MODE; then
        BEST_MODE="balanced"
        WORST_MODE="power-saver"
        echo "modes rebalanced"
    fi
}


battery_threshold_met() {
    battery_percentage=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | awk '/percentage:/ {print $2}')
    battery_percentage="${battery_percentage%\%}" # Remove trailing '%'

    if [ $battery_percentage -gt $THRESHOLD_FOR_BEST_MODE ]; then
        return 0
    else
        return 1
    fi
}


check_dependencies
check_power_modes

ppfmode=$(powerprofilesctl get)
last_used_mode="$ppfmode"

while [[ "$last_used_mode" == "$ppfmode" ]]; do # Exit loop if mode is changed manually

    charging_state=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | awk '/state:/ {print $2}')

    if [[ "$charging_state" == "discharging" ]] || ! battery_threshold_met; then

        # Set to WORST_MODE if not already set
        if [[ "$ppfmode" != "$WORST_MODE" ]]; then
            powerprofilesctl set "$WORST_MODE"
            last_used_mode="$WORST_MODE"
        fi

    elif [[ "$charging_state" == "charging" ]]; then

        # Set to BEST_MODE if not already set and the threshold requirement is met
        if [[ "$ppfmode" != "$BEST_MODE" ]] && battery_threshold_met ; then
            powerprofilesctl set "$BEST_MODE"
            last_used_mode="$BEST_MODE"
        fi
    fi

    sleep $SLEEP_INTERVAL
    ppfmode=$(powerprofilesctl get)
done