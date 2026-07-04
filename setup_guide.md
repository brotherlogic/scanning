# CZUR Scanner Windows 11 VM Setup Guide

This guide will walk you through setting up a Windows 11 Virtual Machine using `virt-install` on your Linux host. The VM is configured to automatically passthrough your CZUR scanner (Vendor ID: `1e4f`, Product ID: `0806`).

## Prerequisites

1. **Windows 11 ISO**: 
   Download the official Windows 11 Install ISO from Microsoft:
   [Download Windows 11 Disk Image (ISO) for x64 devices](https://www.microsoft.com/software-download/windows11)
   Save this file to a known location on your host (e.g., `/var/lib/libvirt/images/` or your `Downloads` folder).

2. **KVM & virt-install**:
   Ensure your host system has the necessary virtualization packages installed. (e.g., `qemu-kvm`, `libvirt-daemon-system`, `libvirt-clients`, `bridge-utils`, `virtinst`, and `swtpm` for the TPM emulator).

## The virt-install Script

Save the following script on your host machine as `setup_scanner_vm.sh`. 

Before running it, you must edit the `ISO_PATH` variable to point to the location where you downloaded the Windows 11 ISO.

```bash
#!/bin/bash
# setup_scanner_vm.sh

# ==========================================
# Configuration Variables
# ==========================================
VM_NAME="czur-scanner-win11"
RAM_MB="8192"         # 8GB RAM recommended for Windows 11
VCPUS="4"             # 4 CPU Cores recommended
DISK_SIZE="60"        # 60GB Disk size in GB
OS_VARIANT="win11"
NETWORK="network=default"

# ⚠️ UPDATE THIS to the path of your downloaded Windows 11 ISO!
ISO_PATH="/path/to/Win11_English_x64v2.iso" 

# ==========================================
# Pre-requisite checks
# ==========================================
if [ ! -f "$ISO_PATH" ]; then
    echo "Error: Windows 11 ISO not found at $ISO_PATH."
    echo "Please download it from Microsoft and update the ISO_PATH variable in this script."
    exit 1
fi

echo "Starting creation of Windows 11 VM for CZUR Scanner..."

# ==========================================
# virt-install Command
# ==========================================
virt-install \
  --name="$VM_NAME" \
  --memory="$RAM_MB" \
  --vcpus="$VCPUS" \
  --os-variant="$OS_VARIANT" \
  --disk size="$DISK_SIZE",bus=virtio,format=qcow2 \
  --network "$NETWORK",model=virtio \
  --graphics spice,listen=127.0.0.1 \
  --video qxl \
  --cdrom="$ISO_PATH" \
  --boot uefi \
  --features smm=on \
  --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
  --hostdev 1e4f:0806,type=usb \
  --noautoconsole

echo "================================================="
echo "VM Creation Triggered Successfully!"
echo "Open 'virt-manager' on your host to view the display and complete the Windows 11 installation."
echo "Note: The CZUR scanner will be passed through to the VM automatically when it boots."
echo "================================================="
```

## Running the Setup

1. On your host machine, create the script file:
   ```bash
   nano setup_scanner_vm.sh
   ```
2. Paste the script above, update `ISO_PATH`, and save it.
3. Make the script executable:
   ```bash
   chmod +x setup_scanner_vm.sh
   ```
4. Run the script (you may need `sudo` depending on your `libvirt` group setup):
   ```bash
   ./setup_scanner_vm.sh
   ```

## Final Steps in Windows
1. Once the script runs, open `virt-manager` (Virtual Machine Manager) on your host.
2. Open the console for `czur-scanner-win11` and proceed through the Windows 11 installation.
3. Once logged into Windows, install the CZUR software. The scanner should already be connected via the USB passthrough.
