source ./driver.sh
source ./lib

for file in `find ./packages -type f`; do
	installpackagesbatch $file
done

for file in `find ./packages/YAY -type f`; do
	yayinstallpackagesbatch $file
done

echo 'Precompiling formats for LaTeX'
sudo fmtutil-sys -all
echo 'Setup Complete.'

