#!/bin/bash

set -e

echo "[INFO] Detecting hardware..."

# Detect CPU vendor
CPU_VENDOR=$(lscpu | grep -i 'Vendor ID' | awk '{print $3}')

# Detect GPU vendor
GPU_INFO=$(lspci | grep -i 'vga\|3d\|display')
GPU_VENDOR="unknown"
if echo "$GPU_INFO" | grep -iq 'nvidia'; then
    GPU_VENDOR="nvidia"
elif echo "$GPU_INFO" | grep -iq 'amd'; then
    GPU_VENDOR="amd"
elif echo "$GPU_INFO" | grep -iq 'intel'; then
    GPU_VENDOR="intel"
fi

echo "[INFO] CPU Vendor: $CPU_VENDOR"
echo "[INFO] GPU Vendor: $GPU_VENDOR"

# Install CPU microcode
if [[ "$CPU_VENDOR" == "GenuineIntel" ]]; then
    echo "[ACTION] Installing Intel microcode..."
    pacman -Sy --noconfirm intel-ucode
elif [[ "$CPU_VENDOR" == "AuthenticAMD" ]]; then
    echo "[ACTION] Installing AMD microcode..."
    pacman -Sy --noconfirm amd-ucode
else
    echo "[WARN] Unknown CPU vendor. Skipping microcode."
fi

# Install GPU drivers
case "$GPU_VENDOR" in
    nvidia)
        echo "[ACTION] Installing NVIDIA drivers..."
	
	# 0. IF YOU HAVE HYBRID GRAPHICS, INTEL
	# sudo pacman -S xf86-video-intel
	# 1. Update system
	sudo pacman -Syu

	# 2. Install kernel headers (choose one that matches your kernel)
	sudo pacman -S linux-headers        # For default kernel
	# sudo pacman -S linux-lts-headers  # If using LTS kernel

	# 3. Install NVIDIA DKMS drivers and utilities
	sudo pacman -S nvidia-dkms nvidia-utils nvidia-settings nvidia-prime cuda cuda-tools cudnn
	
	# 4. Blacklist nouveau
	echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/disable-nouveau.conf

	# 5. Optional: Enable NVIDIA runtime power management (for laptops)
	echo "options nvidia NVreg_DynamicPowerManagement=0x02 NVreg_DynamicPowerManagementVideoMemoryThreshold=100" | sudo tee /etc/modprobe.d/nvidia-power.conf

	# 6. Regenerate initramfs
	sudo mkinitcpio -P

        ;;
    amd)
        echo "[ACTION] Installing AMD GPU drivers..."
        pacman -Sy --noconfirm mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
        ;;
    intel)
        echo "[ACTION] Installing Intel GPU drivers..."
        pacman -Sy --noconfirm mesa xf86-video-intel vulkan-intel lib32-vulkan-intel
        ;;
    *)
        echo "[WARN] Unknown GPU vendor. No drivers installed."
        ;;
esac

echo "[✅ DONE] Driver installation completed based on detected hardware."
