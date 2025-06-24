#!/usr/bin/env bash

# Change this to whatever your virtual machine is named.
# You can run `virsh list --all` to see the names of all of your virtual machines.
vmname="my_virtual_machine"

state=$(virsh domstate $vmname)

if [[ "$state" == "shut off" ]]; then
  virt-manager --connect qemu:///system --show-domain-console $vmname && virsh start $vmname
elif [[ "$state" == "running" ]]; then 
  virsh shutdown $vmname
else
  echo "$vmname is currently $state. Exiting script..."
  exit 1
fi