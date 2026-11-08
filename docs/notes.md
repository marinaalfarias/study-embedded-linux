# stage 0
- compile com ```riscv64-linux-gnu-gcc -static -o hello-world hello-world.c```
- gera o novo arquivo hello-world
- o que há em hello-world
``` 
file hello-world
hello-world: ELF 64-bit LSB executable, UCB RISC-V, RVC, double-float ABI, version 1 (GNU/Linux), statically linked, BuildID[sha1]=0b1b9e75a353aebb09e836a629c38f4d5eda3b6f, for GNU/Linux 4.15.0, not stripped 
```
- saída do terminal após executar o qemu
```
qemu-riscv64 ./hello-world
Hello, world!
```
- diferenças entre esses dois comandos
    - qemu-system-riscv64: emula uma máquina inteira (CPU, memória, etc). é usado para inicializar um kernel Linux. no stage 0 isso não funcionaria porque não há um kernel Linux rodando dentro da máquina virtual.
    - qemu-riscv64: executa apenas um conjunto de instruções para rodar um único arquivo. traduz as chamadas do Linux. é mais leve e rápido.

# stage 1
### Versões e código-fonte
- Kernel: Linux 6.18.57
- Tarball: https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.57.tar.xz
- Toolchain: riscv64-linux-gnu-gcc (versão: X.Y.Z — execute `riscv64-linux-gnu-gcc --version`)
- Diretório de extração: `third_party/linux-6.18/` (relativo à raiz do repositório)

### Comandos executados
```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.57.tar.xz
tar -xf linux-6.18.57.tar.xz
cd linux-6.18.57
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- Image -j$(nproc) 
```

Após baixar o kernel, é hora de tentar executá-lo; para isso, executei o seguinte comando
```
qemu-system-riscv64 -M virt -nographic   -kernel arch/riscv/boot/Image   -append "console=ttyS0"
```
Após esse comando, o OpenSBI rodou conforme esperado e o kernel iniciou. Em algum momento, o log parou e então esta linha apareceu
```
[    1.687155] ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0) ]---
```
Isso aconteceu porque o kernel está funcional, mas precisa de um sistema de arquivos para chegar ao shell

Para usar o BusyBox, usei o seguinte comando
```
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig
```
Então, selecionei a opção **Build static binary (no shared libs)** e executei os seguintes comandos
```
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j$(nproc)
file busybox
```