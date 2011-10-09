packs=libftdi mspdebug avrdude usniffer
pdir=packages/

define do_install
cd packages && mpkg-index && mpkg update && mpkg install $(1)
endef

define run_mkpg
cd $(1) && mkpkg
endef

all: $(packs)
.PHONY: $(packs)


avrdude: libftdi
	$(call run_mkpg,avrdude)
	-$(call do_install, avrdude)

libftdi: 
	$(call run_mkpg,libftdi)
	-$(call do_install,libftdi)

usniffer:
	$(call run_mkpg,usniffer)
	-$(call do_install,usniffer)
mspdebug: 
	$(call run_mkpg,mspdebug)
	-$(call do_install,mspdebug)

