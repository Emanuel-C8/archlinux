source ./lib
git clone https://aur.archlinux.org/yay.git ~/yay
cd ~/yay
makepkg -si
cd -

for file in `find ./packages/YAY -type f`; do
	yayinstallpackagesbatch $file
done


