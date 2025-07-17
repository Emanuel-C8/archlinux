sudo cp conf/dotfiles/.tmux.conf ~/ && (echo '.tmux.conf inserito correttamente') || (echo '.tmux.conf non inserito correttamente')
sudo cp conf/unikeyboard conf/us /usr/share/X11/xkb/symbols 
sudo cp conf/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo cp conf/pacman.conf /etc
