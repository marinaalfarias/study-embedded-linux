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