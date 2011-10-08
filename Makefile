packs=libftdi mspdebug avrdude
pdir=packages/

define do_install
cd packages && mpkg-index && mpkg update && mpkg install $(1)
endef

all: $(packs)
.PHONY: $(packs)


avrdude: libftdi
	cd avrdude && mkpkg
	-$(call do_install, avrdude)

libftdi: 
	cd libftdi && mkpkg
	-$(call do_install,libftdi)

mspdebug: 
	cd mspdebug && mkpkg
	-$(call do_install,mspdebug)

