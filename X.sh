
    echo "Updating system..."
    sudo pacman -Sy --noconfirm

    echo "Installing essential packages for DWM and Xorg..."
    sudo pacman -S --noconfirm \
      base-devel git xorg-server xorg-xinit xorg-xauth xorg-xmessage xorg-xrdb xorg-xprop \
      xf86-input-libinput \
      xorg-xsetroot xorg-xrandr \
      libx11 libxft libxinerama \
      ttf-dejavu ttf-liberation noto-fonts \
      mesa mesa-utils \
      sudo

    # Optional Intel driver (uncomment if Intel GPU detected)
    # sudo pacman -S --noconfirm xf86-video-intel

    echo "Adding user $USER to necessary groups (video, input)..."
    sudo usermod -aG video,input $USER

    echo "Applying new group memberships for this session..."
    newgrp video <<EOF
newgrp input <<EOF2
echo "Group membership updated."
EOF2
EOF

    echo "Cloning suckless repositories..."
    mkdir -p ~/suckless
    cd ~/suckless
    git clone https://git.suckless.org/dwm
    git clone https://git.suckless.org/dmenu
    git clone https://git.suckless.org/st
    cd -
    echo "Building and installing dwm, dmenu, and st locally to ~/.local/bin ..."
    mkdir -p ~/.local/bin
    for app in dwm dmenu st; do
      cd ~/suckless/$app
      sudo make clean install
      cd -
    done

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
      echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
      export PATH=$HOME/.local/bin:$PATH
      echo "Added ~/.local/bin to PATH in ~/.bashrc"
    fi

    echo "Creating ~/.xinitrc to start dwm..."
    echo "exec dwm" > ~/.xinitrc
    chmod +x ~/.xinitrc

    echo ""
    echo "=== Setup complete! ==="
    echo "Make sure to logout and log back in or source ~/.bashrc for PATH changes."
    echo "Start DWM with: startx"
    echo ""
    echo "Tips:"
    echo "- Run 'startx' from a real TTY (Ctrl+Alt+F2 to F6), NOT as root or via ssh."
    echo "- Check /var/log/Xorg.0.log or journalctl for errors if X does not start."
  
