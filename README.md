# Linux Scripts

This repository contains my Linux scripts that are good enough for general use by others. The scripts in this README are arranged top-to-bottom from complex (high potential value) to very simple (you could easily write these on your own). Also check out my [Nemo actions repository](https://github.com/KobeW50/nemo-actions).

**Note that I am new to Linux and scripting. Use these at your own risk.**

Please open an issue if you found bugs, have questions, or want to contribute. Thanks :)
___

# Scripts

### 1. [30-manage-tailscale.sh](/30-manage-tailscale.sh)

This script is useful if you want to disable Tailscale when you connect to certain networks (ie: your home Wi-Fi) and enable Tailscale when connected to any other network. It can easily be modified to perform any command unrelated to Tailscale when these conditions occur.

The script should be stored in `/etc/NetworkManager/dispatcher.d/`. It is invoked by [NetworkManager-dispatcher](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html), which is a daemon that runs scripts in the directory when there are certain changes to the network connection. I suggest that you read more about NetworkManager-dispatcher on the [Arch Wiki](https://wiki.archlinux.org/title/NetworkManager#Network_services_with_NetworkManager_dispatcher), especially if you plan to modify the script so that it functions beyond its intended use.

According to the NetworkManager-dispatcher documentation linked above, the script runs as root, should be owned by root, should be executable, and must not be writable by groups or others.

**Using the script:**
``` shell
# The script depends on the following commands: ip, awk, grep, and tailscale

# You will need to modify the script in a text editor to specify the SSID/name of the Wi-Fi network.
# Read the comments in the script for more details about changes you may want to make.

# Enable the NetworkManager-dispatcher daemon
sudo systemctl enable NetworkManager-dispatcher.service

# Make root the owner of the script
sudo chown root:root 30-manage-tailscale.sh

# Give root write privileges and everyone else read and execute privileges
sudo chmod 755 30-manage-tailscale.sh

# Move script to correct directory
sudo mv 30-manage-tailscale.sh /etc/NetworkManager/dispatcher.d/
```


### 2. [toggle-vm.sh](/toggle-vm.sh)

This script toggles a QEMU-based virtual machine on and off using virsh (ie: the libvirt command-line utility). When toggling on, it opens the virtual machine in virt-manager.

**Using the script:**
``` shell
# You will need to modify the script in a text editor to specify the name of the virtual machine that it should toggle.

# Make the script executable
chmod +x toggle-vm.sh
```
