
# stage 3 - estudo
## documentação buildroot [(link)](https://nightly.buildroot.org/manual.html)
### capítulo 9 - Project-specific cutomization
ações para criar um novo projeto são 
- configurar o Buildroot (build options and toolchain(*), kernel, package and filesystem image type selection)
- configurar outros componentes, como o kernel do linux e busybox
- customizar o target filesystem gerado
    - muitos `BR2_ROOTFS_*` -> ver o que é
- adicionar contas customizadas
- usar comandos aleatórios depois de gerar a imagem do filesystem
- adicionar patches específicos para o projeto para pacotes
- adicionar pacotes específicos para o projeto
#### estrutura recomendada
```bash
+-- board/
|   +-- <company>/
|       +-- <boardname>/
|           +-- linux.config
|           +-- busybox.config
|           +-- <other configuration files>
|           +-- post-build.sh
|           +-- post-image.sh
|           +-- rootfs_overlay/
|           |   +-- etc/
|           |   +-- <some files>
|           +-- patches/
|               +-- foo/
|               |   +-- <some patches>
|               +-- libbar/
|                   +-- <some other patches>
|
+-- configs/
|   +-- <boardname>_defconfig
|
+-- package/
|   +-- <company>/
|       +-- Config.in (if not using a br2-external tree)
|       +-- <company>.mk (if not using a br2-external tree)
|       +-- package1/
|       |    +-- Config.in
|       |    +-- package1.mk
|       +-- package2/
|           +-- Config.in
|           +-- package2.mk
|
+-- Config.in (if using a br2-external tree)
+-- Makefile (if using a custom top makefile)
+-- external.mk (if using a br2-external tree)
+-- external.desc (if using a br2-external tree)

```
- algumas coisas são para empresas (company, boardname) -> lembrar de usar específico para o meu caso
- quase todos os métodos disponíveis de customizar um Buildroot, aceitam um space-separated list of items
- Makefile
    - apontar `BR2_EXTERNAL` e 0 para os espaços certos para construir o build que quiser
    - Makefile básico - no site
#### manter customizações fora do Buildroot
- usar o br2-external para fazer alterações no Buildroot em vez de alterar ele em si
    - permite manter receitas de pacotes, suporte para placas e configuração de placas que estão fora do Buildroot
    - chamado de **b2-external tree**
#### layout de uma br2-external tree
- external.desc*
    - esse arquivo descreve a br2-external tree (nome e descrição para a br2-external tree)
    - cada linha começa com uma *keyword*, seguido por uma *vírgula* e um ou mais *espaços* e o *valor* da keyword
    - keyword **name** é obrigatórioe define o nome para a árvore, o nome deve usar somente ASCII. a variável ***BR2_EXTERNAL_$(NAME)_PATH*** para o absoluto path da árvore. a variável fica disponível no *Kconfig* e no *Makefile*
    - keyword **desc** opcional e dá uma curta descrição para a árvore. deve caber em uma linha, não tem uma forma definida e é usado para mostrar alguma informação sobre a árvore (limite máximo de 40 caracteres). essa descrição fica salva como ***BR2_EXTERNAL_$(NAME)_DESC***
- external.mk* e Config.in*
    - esses arquivos são usados para definir recipes packages ou outra configuração cusotmizada
    - o buildroot adiciona o Config.in automaticamente de cada br-external tree para aparecer no top-level no menu de configuração e inclui o *external.mk* de cada árvore com o resto do makefile
    - o uso principal é para guardar packages recipes
    - Config.in recomendado
    ```bash
    source "$BR2_EXTERNAL_BAR_42_PATH/package/package1/Config.in"
    source "$BR2_EXTERNAL_BAR_42_PATH/package/package2/Config.in"
    ```
    - external.mk recomendado
    ```bash
    include $(sort $(wildcard $(BR2_EXTERNAL_BAR_42_PATH)/package/*/*.mk))
    ```
- configs/
    - pode-se guardar as defconfigs do Buildroot nessa pasta. o Buildroot vai salvar elas automaticamente no output de *make list-defconfigs* e permetir que eles sejam carregados com o comando *make <name>_defconfig*
- provides/
    - para alguns pacotes, o Buildroot deixa escolher entre duas ou mais implementações de API-compatible pacotes. por ezemplo, você pode escolher entre libjpeg ou jpeg-turbo, openssl ou libressl, algumas configurações que não vem pré configuradas
    - provides/jpeg.in, provides/openssl.in, provides/skeleton.in, são os arquivos que vão conter as implementações alternativas desses pacotes
#### salvando a config do buildroot
- `make savedefconfig` -> resulta em um arquivo `defconfig`
- o path desse arquivo dá pra ser alterado com `make savedefconfig BR2_DEFCONFIG=<path-to-defconfig>`
#### salvando a config de outros componentes
as configurações de outros arquivos como BusyBox, Linux kernel, U-Boot etc devem ser salvas se alteradas. para cada um desses componentes, o Buildroot tem uma opção de configuração que vai apontar para um arquivo de configuração de entrada como **BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE**. para guardar essa configuração, salvar em um caminho específico para configurações (board/company/boardname/foo.config)
- `make linux-update-defconfig`: salva as configs do linux para o path especificado em `BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE`
- `make busybox-update-config`: salva as configs do busybox no path `BR2_PACKAGE_BUSYBOX_CONFIG`
#### customizar o target filesystem gerado
além de alterar as cosias a partir do `make *config`, tem alguns outras formas de customziar o target filesystem resultante. tem dois métodos para isso, eles são
- **root filesystem overlays (BR2_ROOTFS_OVERLAY)**
    - o overlay do filesystem é uma árvore de arquivos que é copiado diretamente no target do filesystem depois de ser buildado. para ativar isso, setar a configuração `BR2_ROOTFS_OVERLAY` no system configuration menu para o root do overlay
- **post build scripts (BR2_ROOTFS_BUILD_SCRIPT)**
    - shell scripts chamados depois que o Buildroot builda todo o software esperado, mas antes das imagens do rootfs serem assinaladas. para ativar essa função, especificar uma lista separada por espaços de pós-build scripts

#### customizar depois da imagem já ter sido criada
especificar as configurações no script pós-imagem na opção de configuração **BR2_ROOTFS_POST_IMAGE_SCRIPT** no System configuration menu


#### adicionar pacotes específicos do projeto
devem ser adicionados na pasta *package* e precisa ter dois arquivos, um .mk e um Config.in. o Buildroot vai adicionar o .mk no primeiro nível da pasta *packages* (*package/*/*.mk*) 
#### salvando as customizações
1. `make menuconfig`: configurar toolchain, pacotes e kernel
2. `make linux-menuconfig`: atualizar configs do kernel. sintaxe parecida para outras configurações, como busybox, etc
3. `mkdir -p board/<manufacturer>/<boardname>`
4. setar as opções relevantes
    1. `BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE`
    2. `BR2_PACKAGE_BUSYBOX_CONFIG`
    3. `BR2_PACKAGE_BUSYBOX_CONFIG`
5. escrever os seguintes arquivos de configuração
    1. `make linux-update-defconfig`
    2. `make busybox-update-config`
    3. `make uclibc-update_config`
    4. `cp <output>/build/at91bootstrap3-*/.config board/<manufacturer>/<boardname>/at91bootstrap3.config`
    5. `make barebox-update-defconfig`
    6. `make uboot-update-defconfig`
6. criar `board/<manufacturer>/<boardname>/rootfs-overlay` e preencher com arquivos adicionar que possam ser necessários no rootfs
7. criar `board/<manufacturer>/<boardname>/post-build.sh` e apontar o **BR2_ROOTFS_POST_BUILD_SCRIPT** para esse arquivo
8. para adicionar pacotes adicionar, configurar **BR2_GLOBAL_PATCH_DIR** para `board/<manufacturer>/<boardname>/patches/` e adicionar esse patches em alguma subpasta com o nome do pacote. o patch deve ser algo com `<packagename>-<num>-<description>.patch`
9. `make savedefconfig`: salva a configuração do buildroot
10. `cp defconfig configs/<boardname>_defconfig`

### capítulo 18 - adicionando novos pacotes no buildroot
#### config files
para pacotes usados no target, criar um arquivo chamado `Config.in` que vai conter as descrições das opções relacionadas com a `libfoo` que será usado na ferramenta de configuração
```
config BR2_PACKAGE_LIBFOO
        bool "libfoo"
        help
          This is a comment that explains what libfoo is. The help text
          should be wrapped.

          http://foosoftware.org/libfoo/
```
bool e help - um tab. messagem do help - um tab e dois espaços
1. tipo de opção (bool, string, ...)
2. se necessário, valores `default`
3. quaisquer dependências no target, toolchain e outros pacotes na forma `depends on`
4. quaisquer dependências a forma `select`
5. a mensagem de help
**Config.in.help**: alguns pacotes precisam ser buildados para o host. tem duas opções
- o host package só é necessária para satisfazer o tempo de vuild das dependencias de um ou mais target packages. nesse caso, adicionar `host-foo` no target da variável do pacote `BAR_DEPENDENCIES`. sem necessidade de criar um `Config.in.host`
- o pacote de host deve ser explicitamente selecionável pelo usuário a partir do menu de configuração. nesse caso, criar um `Config.in.host`
```
config BR2_PACKAGE_HOST_FOO
        bool "host foo"
        help
          This is a comment that explains what foo for the host is.

          http://foosoftware.org/foo/
```
finalmente, deve-se adicionar a nova `libfoo/Config.in.host` no `package/Config.in.host`. os arquivos aqui são ordenados de forma alfabética e não devem conter nada alem do bare name do pacote

o host package vai estar disponível no `Host utilities` menu

**Escolher entre `dependes on` ou `select`**: 
- `select`: dependências que não são óbvias, mas faz sentido de ter o kconfig system garantindo que essas dependências estão selecionadas
- `depends on`: quando o usuário precisa estar ativamente ciente dessa dependência
```
config BR2_PACKAGE_RRDTOOL
        bool "rrdtool"
        depends on BR2_USE_WCHAR
        select BR2_PACKAGE_FREETYPE
        select BR2_PACKAGE_LIBART
        select BR2_PACKAGE_LIBPNG
        select BR2_PACKAGE_ZLIB
        help
          RRDtool is the OpenSource industry standard, high performance
          data logging and graphing system for time series data.

          http://oss.oetiker.ch/rrdtool/

comment "rrdtool needs a toolchain w/ wchar"
        depends on !BR2_USE_WCHAR
```
ver tópico 18.2.4 para ver os targets mais comuns

#### dependências em um kernel linux buildado pelo buildroot
comentário a ser adicionado no Config.in
```
foo needs a Linux kernel to be built
foo needs a toolchain w/ featA, featB, featC and a Linux kernel to be built
```
#### dependências no udev /dev management
```
foo needs udev /dev management
foo needs udev /dev management and a toolchain w/ featA, featB, featC
```
#### the .mk file
o arquivo `libfoo.mk` descreve como o pacote deve ser baixado, configurado, buildado, instalado, etc

- **makefiles para pacotes genéricos**: baseados em uma estrutura parecida com a usada para o pacotes baseados no autotools, mas requer um pouco mais de trabalho do dev
- **makefiles para autottools-based software**: deve ser usados para novos pacotes que se baseiem no autotools como seu sistema de build
- **makefiles para cmake-based software**: deve ser usados para novos pacotes que se baseiem em CMake
#### arquivo .hash