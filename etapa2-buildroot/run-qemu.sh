qemu-system-riscv64 -M virt -nographic \
  -bios output/images/fw_jump.bin \
  -kernel output/images/Image \
  -append "rootwait root=/dev/vda ro console=ttyS0" \
  -drive file=output/images/rootfs.ext2,format=raw,if=virtio \
  -netdev user,id=net0 -device virtio-net-device,netdev=net0