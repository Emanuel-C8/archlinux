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
        pacman -Sy --noconfirm nvidia nvidia-utils nvidia-settings cuda-tools cudnn nvidia-prime
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
