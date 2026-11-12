
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
### salvando a config do buildroot
- `make savedefconfig` -> resulta em um arquivo `defconfig`
- o path desse arquivo dá pra ser alterado com `make savedefconfig BR2_DEFCONFIG=<path-to-defconfig>`
