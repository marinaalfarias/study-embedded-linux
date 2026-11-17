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


## Erro: Falha na compilação do GDB (host-gdb-15.2) no Buildroot 2025.02

### Sintoma
Ao compilar o Buildroot com `BR2_PACKAGE_HOST_GDB` habilitado, o processo falha durante a compilação do pacote `host-gdb-15.2`, terminando com `Error 2` e a mensagem `libbfd.la` ou similar.

### Causa Raiz
Incompatibilidade entre o código-fonte do GDB 15.2 (que traz uma cópia interna da biblioteca `readline`) e o GCC 15.x, que é o compilador padrão em versões recentes do Ubuntu. O GCC 15 usa o padrão C23 por padrão, que altera a interpretação de declarações de funções antigas como `int tputs()`, fazendo com que a compilação do `readline` interno falhe com um erro do tipo `too many arguments to function 'tputs'` [citation:1][citation:5].

### Solução Adotada
Como a correção oficial do Buildroot (que envolve fazer o GDB usar o `readline` externo) ainda não estava presente na versão 2025.02 utilizada, a solução mais prática foi **desabilitar a opção `BR2_PACKAGE_HOST_GDB` no `menuconfig`**. Isso permitiu que o restante da imagem (kernel, BusyBox, aplicação contador) fosse compilado com sucesso.

### Observação para a Etapa 3
O Buildroot **não suporta `gdbserver` para a arquitetura RISC-V** [citation:13]. Portanto, a depuração remota (host GDB + gdbserver no target) não é possível nesta configuração. A depuração da aplicação contador precisará ser feita de forma **local**, rodando o GDB dentro do próprio ambiente QEMU.