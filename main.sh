source ./driver.sh
source ./lib

for file in `find ./packages/pacman -type f`; do
	installpackagesbatch $file
done


echo 'Precompiling formats for LaTeX'
sudo fmtutil-sys -all
echo 'Setup Complete.'

