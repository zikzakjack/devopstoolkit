#!/bin/bash

echo "================================================================================"
echo "Diff Production vs BCP Configs"
echo "================================================================================"

ã€€
function takeInput() {
	echo
	read -p "${1} : [To Continue Press (y/n)] [To Abort the Program (q)] ? " choice
	case "$choice" in
		y|Y ) echo "y";;
		n|N ) echo "n";;
		q|Q ) echo "q";;
		* ) takeInput "${1}";;
	esac
	echo
}

ã€€
answer=$( takeInput "Diff myapp01 Configs" )
if [ ${answer} == "y" ]; then
	diff myapp01-prd.properties.orig myapp01-prd.properties.bcpm
	sed -i 's/tcp:\/\/prodhost.zikzakjack.com:7307/tcp:\/\/prodhost.zikzakjack.com:7307,tcp:\/\/bcphost.zikzakjack.com:7307/I' myapp01-prd.properties.bcpm
	sed -i 's/oldhost/newhost/g' myapp01-prd.properties.bcpm
elif [ ${answer} == "n" ]; then
	echo "Diff myapp01 Configs :: Ignored "
else
	exit 1
fi

ã€€
answer=$( takeInput "Diff myapp02 Configs" )
if [ ${answer} == "y" ]; then
	diff myapp02-prd.properties.orig myapp02-prd.properties.bcpm
elif [ ${answer} == "n" ]; then
	echo "Diff myapp02 Configs :: Ignored "
else
	exit 1
fi
