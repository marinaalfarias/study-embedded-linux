Este guia deve ser o "passo a passo para o dia a dia", com os comandos na ordem correta.

# Guia de Replicação e Comandos

## Pré-requisitos
- Ubuntu 22.04+ com os pacotes: `build-essential`, `libncurses-dev`, `wget`, `git`, `bc`, `flex`, `bison`, `cpio`, `rsync`, `python3`.
- Toolchain cruzada: `sudo apt install gcc-riscv64-linux-gnu qemu-user qemu-system-misc`.

## Como gerar a imagem do zero (primeira vez)

1. **Clone o repositório**:
   ```bash
   git clone <url-do-repo>
   cd study-embedded-linux
    ```

2. Baixe o Buildroot (se não estiver em third-party/):

    ```bash
    cd third-party
    wget https://buildroot.org/downloads/buildroot-2025.02.tar.gz
    tar -xf buildroot-2025.02.tar.gz
    cd ..
    ```
3. Configure e compile (usando o defconfig salvo):

    ```bash
    make -C third-party/buildroot-2025.02.19 \
        O=$(pwd)/build-limpo \
        BR2_EXTERNAL=$(pwd)/br2-external \
        qemu_riscv64_contador_defconfig
    ```
4. Compile a imagem:

    ```bash
    make -C third-party/buildroot-2025.02.19 \
        O=$(pwd)/build-limpo \
        BR2_EXTERNAL=$(pwd)/br2-external
    ```
5. Inicie o QEMU:

    ```bash
    cd build-limpo
    qemu-system-riscv64 -M virt -nographic \
    -bios images/fw_jump.bin \
    -kernel images/Image \
    -append "rootwait root=/dev/vda ro console=ttyS0" \
    -drive file=images/rootfs.ext2,format=raw,if=virtio \
    -netdev user,id=net0 \
    -device virtio-net-device,netdev=net0
    ```

6. Como atualizar a imagem após mudanças
Mudou o código do contador (main.c)
    ```bash
    make -C third-party/buildroot-2025.02.19 \
        O=$(pwd)/build-limpo \
        BR2_EXTERNAL=$(pwd)/br2-external \
        contador-reinstall
    ```
7. Depois, regenere a imagem:

    ```bash
    make -C third-party/buildroot-2025.02.19 \
        O=$(pwd)/build-limpo \
        BR2_EXTERNAL=$(pwd)/br2-external
    ```
8. Adicionou um novo pacote no menuconfig
Abra o menuconfig:

    ```bash
    make -C third-party/buildroot-2025.02.19 \
        O=$(pwd)/build-limpo \
        BR2_EXTERNAL=$(pwd)/br2-external \
        menuconfig
    ```
9. Marque o novo pacote, salve e saia.

Force a reinstalação do pacote específico (se for um pacote customizado):

    ```bash
    make ... <nome-do-pacote>-reinstall
    ```
10. Rode o make normal para regenerar a imagem.

Mudou o hostname, senha ou script de init
Rode o menuconfig (para hostname/senha) ou edite o script diretamente no repositório.

Force a regeneração do rootfs (sem recompilar o kernel):

    ```bash
    rm build-limpo/build/buildroot-fs-ext2/.stamp_target_installed
    make -C ... (comando normal)
    Comandos úteis
    Comando	O que faz
    make ... menuconfig	Abre a interface de configuração.
    make ... savedefconfig BR2_DEFCONFIG=...	Salva a configuração atual em um defconfig.
    make ... <pacote>-reinstall	Reinstala apenas o pacote especificado no target/.
    make ... <pacote>-rebuild	Recompila e reinstala o pacote.
    make ...	Gera a imagem final (rootfs.ext2, Image, etc.).
    ```
11. Como sair do QEMU
Pressione Ctrl+a e depois x.