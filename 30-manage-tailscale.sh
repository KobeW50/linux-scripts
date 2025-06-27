#!/usr/bin/env bash

# Change this to whatever your home netowrk SSID/name is. 
# You can run `nmcli -g name con show --active` to see the networks you are currently connected to.
ssid="my_home_wifi"

# The tailscale daemon (I presume) makes this connection on system boot.
tailscaleName="tailscale0"

# This will make it so that any ethernet connection will be treated like the Wi-Fi network above.
# You can run `nmcli -g name con show --active` while connected via ethernet to ensure that this variable's value is correct.
# If you don't want ethernet connections to be treated like the Wi-Fi network above, remove this line and edit the 'if' statement below.
otherTrustedConnection="Wired connection"

# This script is supplied with the action that triggered it as the second argument.
# The CONNECTION_ID is an environment variable available to the script.
# https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html

if [[ "$2" == "up" ]]; then
  # Check if the ssid, startup tailscale connection, or other trusted connection was connected
  if echo "$CONNECTION_ID" | grep -Eq $ssid|$otherTrustedConnection|$tailscaleName"; then
    tailscale down
  else
    tailscale up
  fi
fi
