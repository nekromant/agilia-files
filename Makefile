#dirs to exclude from mass build'n'install
exclude= . sources packages .git
#dir where packages are placed
pdir=../packages
arch=x86_64
repo=astra:/data/www/htdocs/agilia/x86_64
#dummy packages that are not built in this repository, but are
#listed in build_deps
dummies=libusb
######BLACK MAGIC GOES BELOW######
define do_install
cd $(pdir) && mpkg-index && mpkg update && mpkg install -y $(1)
endef

define run_mkpg
cd $(1) && mkpkg
endef

define package
$(1): $(2)
	$(call run_mkpg,$(1))
	-$(call do_install,$(1))
endef

define dummy_pack
$(1): 
	$(info $(1) is a dummy target)
endef

define get_build_dep
$(shell source $(1)/ABUILD; echo $$build_deps)
endef

dirs = $(patsubst ./%,%,$(shell find . -type d -maxdepth 1))
dirs := $(filter-out $(exclude), $(dirs))
$(info processing: $(dirs))

indexfiles=index.log package_list setup_variants.list package_list.html packages.xml.* 

all: $(dirs)
.PHONY: $(dirs) $(dummies) index

purge:
	$(foreach f,$(packs),mpkg-remove $f)

index:
	cd $(pdir) && mpkg-index


genhtml: index
	cat $(pdir)/package_list|while read line;\
	do echo "$$line<br>";\
	done  > $(pdir)/package_list.html

push-%: genhtml
	cd $(pdir);\
	scp $(indexfiles) *$** $(repo)

%-i: %
	-$(call do_install, $^)


$(foreach dir,$(dirs),$(eval $(call package,$(dir),$(call get_build_dep,$(dir)))))
