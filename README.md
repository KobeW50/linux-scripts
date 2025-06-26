# Linux Scripts

This repository contains my Linux scripts that are good enough for general use by others. 

The scripts in this README are arranged top-to-bottom from complex (high potential value) to very simple (you could easily write these on your own).

**Note that I am new to Linux and scripting. Use these at your own risk.**

Please open an issue if you found bugs, have questions, or want to contribute. Thanks :)
___

### [30-manage-tailscale.sh](/30-manage-tailscale.sh)

This script is useful if you want to disable Tailscale when you connect to certain networks (ie: your home Wi-Fi) and enable Tailscale when connected to any other network. It can easily be modified to perform any command unrelated to Tailscale when these conditions occur.

The script should be stored in `/etc/NetworkManager/dispatcher.d/`. It is invoked by [NetworkManager-dispatcher](https://networkmanager.dev/docs/api/latest/NetworkManager-dispatcher.html), which is a daemon that runs scripts in the directory when there are certain changes to the network connection. I suggest that you read more about NetworkManager-dispatcher on the [Arch Wiki](https://wiki.archlinux.org/title/NetworkManager#Network_services_with_NetworkManager_dispatcher), especially if you plan to modify the script so that it functions beyond its intended use.

According to the NetworkManager-dispatcher documentation linked above, the script runs as root, should be owned by root, should be executable, and must not be writable by groups or others.

**Using the script:**
```
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


### [fake-symlink.sh](/fake-symlink.sh)

This script is for Nemo users who hate that directory symbolic links (symlinks) in Nemo don't "Follow link to original file". Rather, Nemo shows you a mirror of the linked directory, from which you can't navigate to the parent of the linked directory.

**How it works:**
Nemo has a feature where you can trigger a script from the right-click context menu. When you activate this script while folders are selected, the script will create an application shortcut (ie: a `.desktop` file) that opens the folder in Nemo when clicked. The application shortcut is created in the directory you are currently in. (If the script is ran on anything that isn't a directory then normal symlinks will be created for those items.)

**Demo:**
<img src="/assets/nemo-script-demo.gif" width="1200"/>

**Limitations:**
- You can't copy/move items into the shortcut.
- Folder shortcuts will open in a new tab instead of the current tab.
- Applications don't treat the shortcuts as symlinks. The shortcuts are just meant for navigation within Nemo.
- It only works on local folders/files (ie: not web content, FTP content, etc.).
- Sometimes you need to refresh the tab for the shortcuts to appear. But this is very rare.
- This script was only tested on Linux Mint 22 Cinnamon with Nemo 6.2.8.

**Using the script:**
```
# Make the script executable
chmod +x fake-symlink.sh

# Move the script to the Nemo script directory
mv fake-symlink.sh ~/.local//share/nemo/scripts/

# See the GIF below to learn how to enable scripts in Nemo and activate the script
```
<img src="/assets/nemo-script-preferences.gif" width="1200"/>


### [toggle-vm.sh](/toggle-vm.sh)

This script toggles a QEMU-based virtual machine on and off using virsh (ie: the libvirt command-line utility). When toggling on, it opens the virtual machine in virt-manager.

**Using the script:**
```
# You will need to modify the script in a text editor to specify the name of the virtual machine that it should toggle.

# Make the script executable
chmod +x toggle-vm.sh
```
