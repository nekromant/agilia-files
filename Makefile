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
dirs := $(filter-out $(addprefix $(repo)/,$(exclude)), $(dirs))
dirsu=$(filter-out $(exclude_upstream),$(dirs))



define dummy_rule
$(1): 
	mpkg install $(1)
endef

define do_install
cd $(pdir) && mpkg install -y $(1)*
endef

define make_stamp
$(addsuffix .$(repo).$(2),$(addprefix $(stampdir)/,$(1)))
endef

define run_mkpg
cd $(1) && mkpkg $(bumps)
endef

define move_package
cd $(pdir) && mv $(1)* $(pdir)/$(repo)/
endef

define package
$(info $(1) $(2) $(3))
$(1) : $(call make_stamp,$(2),built)
	@echo Package $(1) has been created successfully

$(call make_stamp,$(2),built): $(call make_stamp,$(3),built) $(addsuffix /ABUILD,$(1)) 
	-cd $(pdir) && rm $(1)*
	$(call run_mkpg,$(1))
	-$(call do_install,$(2))
	$(call move_package,$(2))
	-rm $(pdir)/$(repo)/$(2).files.html
	tar -tf $(pdir)/$(repo)/$(2)* |while read line;\
	do echo "$$$${line}<br>";\
	done > $(pdir)/$(repo)/$(2).files.html
	touch $(call make_stamp,$(2),built)

$(call make_stamp,$(2),pushed): $(call make_stamp,$(2),built)
	./agiload.sh $(pdir)/$(repo)/$(2)*.txz
	touch $(call make_stamp,$(2),pushed)

pushqueue+=$(call make_stamp,$(2),pushed)

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
	cat $(pdir)/$(repo)/package_list|while read line;\
	do echo "$$line<br>";\
	done  > $(pdir)/$(repo)/package_list.html

pushindex: genhtml
	cd $(pdir)/$(repo);\
	scp $(indexfiles) $(repo)

rsync: 
	rsync -arv --delete-after $(rsyncextra) $(pdir)/$(repo)   $(url_$(repo))

purge:
	mpkg remove $(patsubst $(repo)/%,%,$(dirs))
	-rm -f $(pdir)/$(repo)/*
	-rm -f $(stampdir)/*

$(foreach dir,$(dirs),$(eval $(call package,$(dir),$(patsubst $(repo)/%,%,$(dir)),$(call get_build_dep,$(dir)))))
# $(foreach dummy,$(dumies),$(eval $(call dummy_rule,$(dummy))))


agiload: $(pushqueue)
	echo "Pushed, ok"

index:
	cd $(pdir)/$(repo) && mpkg-index

stat:
	@echo "To push: $(call make_stamp,$(dirsu),pushed)"

