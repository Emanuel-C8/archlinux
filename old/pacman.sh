source ./lib
fullupgrade
for file in `find ./packages/pacman -type f`; do
   installpackagesbatch $file
done
