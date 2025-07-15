source ./driver.sh
source ./lib

for file in `find ./packages -type f`; do
	installpackagesbatch $file
done

echo 'Precompiling formats for LaTeX'
sudo fmtutil-sys -all
echo 'Copying file configurations in the local machine'
sudo cp conf/dotfiles/.tmux.conf ~/
sudo cp conf/unikeyboard conf/us /usr/share/X11/xkb/symbols
sudo cp conf/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf
sudo cp conf/pacman.conf /etc
echo 'Setup Complete.'

