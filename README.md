# MBR-lock
Tool to tweak your USB key and lock it by booting on it from your bios

- To try the tool by emulating it on qemu :

  `./run-on-qemu.sh`
  
- To view connected devices :

  `./tweak-key.sh`

- To tweak your key :

  `./tweak-key.sh sdx` (where sdx is the device : sda, sdb, ...)
  
If you made a mistake, the old MBR of your key will be store in the "save.mbr" file
