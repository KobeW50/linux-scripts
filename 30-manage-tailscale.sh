#!/usr/bin/env bash

# This script is supplied with the action that triggered it as the second argument.
# The CONNECTION_ID is an environment variable available to the script.
# https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html

ssid="my home wifi"
otherTrustedConnection="Wired connection"

if [[ "$2" == "up" ]]; then

  # Check that dependencies are met
  for dependency in ip awk grep tailscale; do
    if ! command -v "$dependency"; then
      exit 1
    fi
  done


  # Get array of network interfaces
  networkInterfaces=( $(ip -br link show | awk '{print $1}') )

  found=false
  for interface in "${networkInterfaces[@]}"; do
  
    if [[ "$interface" == "$CONNECTION_ID" ]]; then
      # Connection is just a network interface and can be ignored
      found=true
      break
    fi
  done


  if ! $found; then # If connection is not a network interface

    if echo "$CONNECTION_ID" | grep -Eq "$ssid|$otherTrustedConnection"; then
      tailscale set --exit-node= && tailscale down
    else
      tailscale up
    fi
  fi
fi