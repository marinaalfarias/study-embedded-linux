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

# Estudo Dirigido: Linux Embarcado em RISC-V

Este repositório documenta a construção de um sistema Linux embarcado para RISC-V, desde um "Hello World" até uma aplicação customizada rodando no emulador QEMU.

## Visão Geral do Projeto

O projeto foi dividido em três etapas principais, seguindo o roteiro do guia:

### Etapa 0: Ambiente e Hello World
- **Objetivo**: Configurar o ambiente de compilação cruzada e executar um binário RISC-V simples.
- **O que foi feito**:
  - Instalação do compilador cruzado (`gcc-riscv64-linux-gnu`) e do QEMU (`qemu-user` e `qemu-system-misc`).
  - Criação de um `hello.c` e compilação estática com `-static`.
  - Execução no QEMU em modo *user* (`qemu-riscv64 ./hello`).
- **Conceito chave**: Diferença entre `qemu-riscv64` (emula apenas a CPU para um programa) e `qemu-system-riscv64` (emula uma máquina completa para um kernel).

### Etapa 1: Linux Mínimo Feito à Mão
- **Objetivo**: Construir manualmente um kernel Linux + initramfs para entender o papel de cada componente.
- **O que foi feito**:
  - Compilação do kernel Linux (versão longterm, ex: 6.18) com `ARCH=riscv`.
  - Boot sem rootfs para observar o kernel panic (`VFS: Unable to mount root fs`).
  - Compilação do BusyBox estático e criação de um initramfs no formato `cpio` (`newc`).
  - Criação do script `/init` (PID 1) que monta `/proc`, `/sys`, `/dev` e executa o shell.
  - Boot completo até o shell.
- **Conceito chave**: O kernel não sabe o que fazer sem um rootfs; o BusyBox fornece os utilitários; o `/init` é o primeiro processo em espaço de usuário.

### Etapa 2: Buildroot (Automação)
- **Objetivo**: Gerar a mesma imagem (ou melhor) usando o Buildroot, automatizando a compilação do kernel, toolchain, BusyBox e rootfs.
- **O que foi feito**:
  - Utilização do Buildroot 2025.02 (LTS) com `qemu_riscv64_virt_defconfig`.
  - Customização via `menuconfig`: hostname (`maridev`), senha de root e instalação do pacote `nano`.
  - Criação de um build "limpo" (`build-limpo`) usando o modo *out-of-tree* (`O=`) para garantir a reprodutibilidade.
  - Comparação: o Buildroot automatizou a toolchain, o OpenSBI (`fw_jump.bin`), o kernel e o rootfs (`rootfs.ext2`), que antes foram feitos manualmente.
- **Conceito chave**: O Buildroot é um sistema de build que resolve dependências e gera uma imagem completa, ideal para projetos embarcados.

### Etapa 3: Sua Aplicação na Imagem
- **Objetivo**: Adicionar uma aplicação customizada (um contador em C) na imagem, fazê-la iniciar no boot e depurá-la.
- **O que foi feito**:
  - Criação de uma árvore externa (`br2-external`) para não modificar o código-fonte do Buildroot.
  - Escrita do pacote `contador` (com `Config.in` e `contador.mk`) usando `SITE_METHOD = local`.
  - Criação do script `S99contador` para iniciar a aplicação via BusyBox init.
  - Compilação e instalação do pacote na imagem final.
  - **Limitação**: O GDB do host não compilou (incompatibilidade com GCC 15) e o `gdbserver` não é suportado para RISC-V no Buildroot. A depuração foi feita localmente (ou documentada como limitação).

## Estrutura do Repositório

- `third-party/`: Fontes baixadas (Buildroot, kernel, BusyBox) - **não versionado**.
- `br2-external/`: Pacote `contador` e customizações do projeto (versionado).
- `build-limpo/`: Diretório de build do Buildroot (gerado, não versionado).
- `docs/`: Documentação (este arquivo, troubleshooting, etc.).
- `scripts/`: Scripts auxiliares (build, run-qemu).

## Como Reproduzir

Consulte o arquivo `REPLICAR.md` para o passo a passo de como gerar a imagem do zero.