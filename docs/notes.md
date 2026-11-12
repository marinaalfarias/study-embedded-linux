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
# stage 2 — Customização

- Hostname alterado para `maridev` (confirmado no prompt de login).
- Senha de root configurada e login funcionando.
- Pacote extra: [nano/htop/tree] instalado via `Target packages`, confirmado com
    ``` # nano --version
    GNU nano, version 8.2
    Compiled options: --enable-tiny --disable-nls --disable-utf8 
    ```
- Aprendizado: o prompt `maridev login:` mostra o hostname, não o usuário. O login é feito com `root`.
### Comandos utilizados
- Comando configuração base: ```make qemu_riscv64_virt_defconfig```
- Comando boot do QEMU: `qemu-system-riscv64 -M virt -nographic   -kernel arch/riscv/boot/Image   
-append "console=ttyS0"`

## Buildroot

### Versão e Configuração
- **Versão do Buildroot**: 2025.02.19 (LTS)
- **Configuração base**: `qemu_riscv64_virt_defconfig`
- **Customizações**: Hostname (`maridev`), senha de root e pacote `nano` (com otimização de tamanho).
- **Defconfig salvo**: `etapa2-buildroot/configs/custom_config`

### Comando de Boot no QEMU
```bash
qemu-system-riscv64 -M virt -nographic \
  -bios output/images/fw_jump.bin \
  -kernel output/images/Image \
  -append "rootwait root=/dev/vda ro console=ttyS0" \
  -drive file=output/images/rootfs.ext2,format=raw,if=virtio \
  -netdev user,id=net0 -device virtio-net-device,netdev=net0
```