# descreve como o pacote deve ser baixado, configurado, buildado, etc
# pacote genérico
CONTADOR_VERSION = 1.0
CONTADOR_SITE = $(BR2_EXTERNAL_CONTADOR_PATH)/package/contador/src
CONTADOR_SITE_METHOD = local

define CONTADOR_BUILD_CMDS
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define CONTADOR_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/contador $(TARGET_DIR)/usr/bin/contador
endef

define CONTADOR_INSTALL_INIT_SYSV
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CONTADOR_PATH)/package/contador/S99contador \
        $(TARGET_DIR)/etc/init.d/S99contador
endef

$(eval $(generic-package))