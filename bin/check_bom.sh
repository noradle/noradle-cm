# usage, example
# find . -exec check_bom.sh {} \;
echo
echo $1
head $1 | hexdump | head -1
