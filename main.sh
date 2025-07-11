source ./lib

for file in `find ./packages -type f`; do
	installpackages $file
done

