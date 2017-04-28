#!/bin/bash

nasm -f bin mbr-lock.asm -o mbr-lock.img
qemu-system-x86_64 -drive file=mbr-lock.img,index=0,media=disk,format=raw
hexdump -C mbr-lock.img
rm mbr-lock.img

