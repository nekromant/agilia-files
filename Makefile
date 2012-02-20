#dir where packages are placed
#Include config
-include config.sys.mk
#include repo config
-include config.repo.mk

repo=stable

exclude = . .git $(broken) 
bump?=n
ifeq ($(bump),y)
	bumps=-ib
else
	bumps=
endif

######BLACK MAGIC GOES BELOW######

dirs = $(patsubst ./%,%,$(filter-out $(repo),$(shell find $(repo) -type d -maxdepth 1)))
dirs := $(filter-out $(exclude), $(dirs))
dirsu=$(filter-out $(exclude_upstream),$(dirs))



define dummy_rule
$(1): 
	mpkg install $(1)
endef

define do_install
cd $(pdir) && mpkg install -y $(1)*
endef

define make_stamp
$(addsuffix .$(repo).stamp,$(addprefix $(stampdir)/,$(1)))
endef

define run_mkpg
cd $(1) && mkpkg $(bumps)
endef

define move_package
cd $(pdir) && mv $(1)* $(pdir)/$(repo)/
endef

define package
$(info $(1) $(2) $(3))
$(1) : $(call make_stamp,$(2))
	@echo Package $(1) has been created successfully

$(call make_stamp,$(2)): $(call make_stamp,$(3)) $(addsuffix /ABUILD,$(1)) 
	-cd $(pdir) && rm $(1)*
	$(call run_mkpg,$(1))
	-$(call do_install,$(2))
	$(call move_package,$(2))
	-rm $(pdir)/$(repo)/$(2).files.html
	tar -tf $(pdir)/$(repo)/$(2)* |while read line;\
	do echo "$$$${line}<br>";\
	done > $(pdir)/$(repo)/$(2).files.html
	touch $(call make_stamp,$(2))

$(call make_stamp,push-$(2)): $(call make_stamp,$(1)) $(call make_stamp,$(addprefix push-,$(3)))
	./agiload.sh $(pdir)/$(1)*.txz
	touch $(call make_stamp,push-$(1))

pushqueue+=$(call make_stamp,push-$(1))

endef


define get_build_dep
$(filter-out $(dummies),$(shell source $(1)/ABUILD; echo $$build_deps))
endef


$(info processing: $(dirs))

indexfiles=index.log package_list setup_variants.list package_list.html packages.xml.* 

 

all: $(pdir)/$(repo) $(dirs) index

$(pdir)/$(repo):
	@echo "Creating package directory..."
	mkdir -p $(pdir)/$(repo)
	
.PHONY: purge pushindex $(dirs) all

genhtml: index
	cat $(pdir)/package_list|while read line;\
	do echo "$$line<br>";\
	done  > $(pdir)/package_list.html

pushindex: genhtml
	cd $(pdir);\
	scp $(indexfiles) $(repo)

push: 
	rsync -arv --delete-after $(rsyncextra) $(pdir)/   $(repo)
purge:
	mpkg remove $(dirs)
	-rm -f $(pdir)/*
	-rm -f $(stampdir)/*

$(foreach dir,$(dirs),$(eval $(call package,$(dir),$(patsubst $(repo)/%,%,$(dir)),$(call get_build_dep,$(dir)))))
# $(foreach dummy,$(dumies),$(eval $(call dummy_rule,$(dummy))))


push-testing: $(call make_stamp,$(addprefix push-,$(dirsu)))
	echo "Pushed, ok"

index:
	cd $(pdir) && mpkg-index

stat:
	@echo "To push: $(call make_stamp,$(dirsu))"

