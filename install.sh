chmod +x driver.sh X.sh addconf.sh pacman.sh yay.sh

./X.sh

sudo ./driver.sh

./pacman.sh

./yay.sh

./addconf.sh

echo 'Compiling LaTeX'
git clone https://github.com/LazyVim/starter ~/.config/nvim
sudo fmtutil-sys -all
