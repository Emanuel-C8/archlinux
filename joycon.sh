#!/bin/bash
# Joy-Con USB setup script for Arch Linux (N1-320)

# 1. Check required AUR packages
echo "Verifying AUR packages..."
for pkg in jstest-gtk-git antimicrox-git xboxdrv-git joycond-git; do
    if ! pacman -Q $pkg &>/dev/null && ! yay -Q $pkg &>/dev/null; then
        echo "Installing $pkg from AUR..."
        yay -S --noconfirm $pkg
    else
        echo "$pkg already installed"
    fi
done

# 2. Enable and start joycond for rumble/motion
echo "Starting joycond..."
sudo systemctl enable --now joycond

# 3. Detect Joy-Con USB device
DEVICE=$(ls /dev/input/by-id/ | grep -i "joy" | head -n1)
if [ -z "$DEVICE" ]; then
    echo "Joy-Con device not found! Connect it via USB and try again."
    exit 1
fi
DEV_PATH="/dev/input/by-id/$DEVICE"
echo "Detected Joy-Con: $DEV_PATH"

# 4. Start xboxdrv for XInput emulation
echo "Starting xboxdrv..."
sudo xboxdrv --evdev $DEV_PATH \
             --evdev-absmap ABS_X=x1,ABS_Y=y1 \
             --evdev-absmap ABS_RX=x2,ABS_RY=y2 \
             --evdev-keymap BTN_A=a,BTN_B=b,BTN_X=x,BTN_Y=y \
             --silent &

# 5. Optional: launch jstest-gtk for testing
echo "Launching jstest-gtk for testing..."
jstest-gtk &

echo "Joy-Con USB setup complete! Use antimicrox if you need custom key mapping."
