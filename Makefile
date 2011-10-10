packs=libftdi mspdebug avrdude usniffer kicad iverilog kicad-libs-base kicad-libs-leaf
pdir=packages/

define do_install
cd packages && mpkg-index && sudo mpkg update && sudo mpkg -y install $(1)
endef

define run_mkpg
cd $(1) && mkpkg
endef

define package
$(1): $(2)
	$(call run_mkpg,$(1))
	-$(call do_install,$(1))
endef


all: $(packs)
.PHONY: $(packs)

purge:
	$(foreach f,$(packs),mpkg-remove $f)

%-i: %
	-$(call do_install, $^)

$(eval $(call package,avrdude,libftdi))
$(eval $(call package,libftdi,))
$(eval $(call package,kicad,))
$(eval $(call package,kicad-libs-base,))
$(eval $(call package,usniffer,))
$(eval $(call package,mspdebug,))
$(eval $(call package,iverilog))
$(eval $(call package,kicad-libs-leaf))
# 
# avrdude: libftdi
# 	$(call run_mkpg,avrdude)
# 	
# 
# libftdi: 
# 	$(call run_mkpg,libftdi)
# 	-$(call do_install,libftdi)
# kicad: kicad-libs-base
# 	$(call run_mkpg,kicad)
# 	-$(call do_install,kicad)
# usniffer:
# 	$(call run_mkpg,usniffer)
# 	-$(call do_install,usniffer)
# mspdebug: 
# 	$(call run_mkpg,mspdebug)
# 	-$(call do_install,mspdebug)
# 
