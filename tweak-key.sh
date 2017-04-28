#!/bin/bash

if [ "$#" == 1 ]
then
    if [ ! -e /dev/$1 ]
    then
	echo "$1: No such drive"
    else
	read -r -p "Are you sure to rewrite the MBR of $1 ? [y/N] " response
	if [[ "$response" =~ ^([yY])+$ ]]
	then
	    sudo dd if=/dev/$1 of=save.mbr bs=512 count=1
	    nasm -f bin mbr-lock.asm -o mbr-lock.img
	    tail -c 66 save.mbr | dd of=mbr-lock.img bs=1 seek=446 count=66 conv=notrunc
	    sudo dd if=mbr-lock.img of=/dev/$1 bs=512 count=1
	    rm mbr-lock.img
	fi
    fi
else
    echo "USAGE: ./tweak-key.sh sdx"
    echo ""
    echo "Select your drive :"
    echo ""
    lsblk -d
fi
