source ./driver.sh
source ./lib

for file in `find ./packages/pacman -type f`; do
	installpackagesbatch $file
done


echo 'Precompiling formats for LaTeX'
sudo fmtutil-sys -all
echo 'Installing jrnl'
pip install jrnl --break-system-packages
echo 'Setup Complete.'

