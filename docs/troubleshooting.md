## Erro: kernel panic — Attempted to kill init! exitcode=0x00000004 (Illegal Instruction)

### Sintoma
Ao iniciar com `qemu-system-riscv64 -M virt -nographic -kernel Image -initrd initramfs.cpio.gz -append "console=ttyS0"`, o kernel executou o /init mas imediatamente entrou em panic:
```
[ 1.231645] status: 0000000200004020 badaddr: 00000000cd817057 cause: 0000000000000002
[ 1.235195] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000004
```

`cause: 2` = Illegal Instruction; `exitcode=0x00000004` = SIGILL.

### Causa raiz
O BusyBox foi compilado pelo `riscv64-linux-gnu-gcc` com o conjunto de instruções padrão (provavelmente rv64gc, incluindo extensão C de instruções comprimidas), mas o modelo de CPU padrão do QEMU não expõe essas extensões. Quando o BusyBox em espaço de usuário executou a primeira instrução que a CPU não reconhecia, disparou SIGILL; o PID 1 não pode receber SIGILL, e o kernel entrou em panic.

### Solução
Adicionar `-cpu rv64` ao comando do QEMU (ou `-cpu max`):

```bash
qemu-system-riscv64 -M virt -cpu rv64 -nographic \
  -kernel .../Image -initrd initramfs.cpio.gz -append "console=ttyS0"
```

## Erro: `make menuconfig` — "Your display is too small to run Menuconfig!"

### Sintoma
Ao executar `make menuconfig`, o Buildroot aborta com:
`It must be at least 19 lines by 80 columns.`

### Causa
A janela do terminal é menor que o tamanho mínimo exigido pela interface do Buildroot.

### Solução
Aumentar a janela do terminal ou maximizá-la. O `menuconfig` abre normalmente.