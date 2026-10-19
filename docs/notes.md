# stage 0
- compile with ```riscv64-linux-gnu-gcc -static -o hello-world hello-world.c```
- generates the new file hello-world
- what is in hello-world
``` 
file hello-world
hello-world: ELF 64-bit LSB executable, UCB RISC-V, RVC, double-float ABI, version 1 (GNU/Linux), statically linked, BuildID[sha1]=0b1b9e75a353aebb09e836a629c38f4d5eda3b6f, for GNU/Linux 4.15.0, not stripped 
```
- terminal output after running qemu
```
qemu-riscv64 ./hello-world
Hello, world!
```
- differences between these two commands
    - qemu-system-riscv64: emulates a whole machine (CPU, memory, etc). its used to initialize a Linux kernel. the stage 0 it wouldn't work here because it doesn't have a Linux kernel running inside the virtual machine.
    - qemu-riscv64: executes just a set of instructions to run a single file. translates the Linux calls. it's lighter and faster.

# stage 1
### Versions and source
- Kernel: Linux 6.18.57
- Tarball: https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.57.tar.xz
- Toolchain: riscv64-linux-gnu-gcc (version: X.Y.Z — run `riscv64-linux-gnu-gcc --version`)
- Extraction directory: `third_party/linux-6.18/` (relative to the repository root)

### Commands executed
```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.57.tar.xz
tar -xf linux-6.18.57.tar.xz
cd linux-6.18.57
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- Image -j$(nproc)