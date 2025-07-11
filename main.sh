source ./lib

for file in `find ./packages -type f`; do
	installpackagesbatch $file
done

