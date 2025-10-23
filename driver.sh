#!/bin/bash

set -e

echo "[INFO] Detecting hardware..."

# Detect CPU vendor
CPU_VENDOR=$(lscpu | grep -i 'Vendor ID' | awk '{print $3}')

# Detect GPU vendor(s)
GPU_INFO=$(lspci | grep -i 'vga\|3d\|display')
HAS_NVIDIA=false
HAS_AMD=false
HAS_INTEL=false

if echo "$GPU_INFO" | grep -iq 'nvidia'; then
    HAS_NVIDIA=true
fi
if echo "$GPU_INFO" | grep -iq 'amd'; then
    HAS_AMD=true
fi
if echo "$GPU_INFO" | grep -iq 'intel'; then
    HAS_INTEL=true
fi

echo "[INFO] CPU Vendor: $CPU_VENDOR"
echo "[INFO] GPU(s) detected: $(echo "$GPU_INFO" | awk -F': ' '{print $2}')"

# Install CPU microcode
if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    echo "[ACTION] Installing Intel microcode..."
    sudo pacman -Sy --noconfirm intel-ucode
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    echo "[ACTION] Installing AMD microcode..."
    sudo pacman -Sy --noconfirm amd-ucode
else
    echo "[WARN] Unknown CPU vendor. Skipping microcode."
fi

# Install GPU drivers
if $HAS_NVIDIA; then
    echo "[ACTION] Installing NVIDIA drivers..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm linux-headers nvidia-dkms nvidia-utils nvidia-settings nvidia-prime cuda cuda-tools cudnn

    # Disable nouveau
    echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/disable-nouveau.conf >/dev/null

    # Enable power management (for laptops)
    echo "options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_DynamicPowerManagementVideoMemoryThreshold=100" | sudo tee /etc/modprobe.d/nvidia-power.conf >/dev/null

    sudo mkinitcpio -P
fi

if $HAS_AMD; then
    echo "[ACTION] Installing AMD GPU drivers..."
    sudo pacman -Sy --noconfirm mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
fi

if $HAS_INTEL; then
    echo "[ACTION] Installing Intel GPU drivers..."
    sudo pacman -Sy --noconfirm mesa xf86-video-intel vulkan-intel lib32-vulkan-intel
fi

# Handle hybrid GPU setups
if $HAS_NVIDIA && $HAS_INTEL; then
    echo "[INFO] Hybrid Intel + NVIDIA system detected (Optimus)."
    echo "[ACTION] Installing PRIME utilities..."
    sudo pacman -Sy --noconfirm nvidia-prime

    REAL_USER=${SUDO_USER:-$USER}
    echo "[ACTION] Adding $REAL_USER to 'video' group..."
    sudo gpasswd -a "$REAL_USER" video
    echo "[INFO] You may need to log out or reboot for group changes to apply."
fi

if $HAS_AMD && $HAS_INTEL; then
    echo "[INFO] Hybrid Intel + AMD system detected. Usually handled automatically by Mesa."
    REAL_USER=${SUDO_USER:-$USER}
    echo "[ACTION] Ensuring $REAL_USER is in 'video' group..."
    sudo gpasswd -a "$REAL_USER" video
fi

echo "[✅ DONE] Driver installation completed based on detected hardware."
