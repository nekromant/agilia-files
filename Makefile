#dir where packages are placed
pdir=../packages
arch=x86_64
repo=invyl.ath.cx:/data/www/htdocs/agilia/x86_64
stampdir=../stamps

broken = xilinx_ise_webpack freecad 
exclude = . .git $(broken) 
#dummy packages that are not built in this repository, but are
#listed in build_deps
dummies=libusb
bump?=n
ifeq ($(bump),y)
	bumps=-ib
else
	bumps=
endif

######BLACK MAGIC GOES BELOW######

define dummy_rule
$(1): 
	mpkg install $(1)
endef

define do_install
cd $(pdir) && mpkg install -y $(1)*
endef

define make_stamp
$(addsuffix .built,$(addprefix $(stampdir)/,$(1)))
endef

define run_mkpg
cd $(1) && mkpkg $(bumps)
endef

define package
$(1) : $(call make_stamp,$(1))
	@echo $(1) has been created successfully

$(call make_stamp,$(1)): $(call make_stamp,$(2)) $(addsuffix /ABUILD,$(1)) 
	-cd $(pdir) && rm $(1)*
	$(call run_mkpg,$(1))
	-$(call do_install,$(1))
	-rm $(pdir)/$(1).files.html
	tar -tf $(pdir)/$(1)* |while read line;\
	do echo "$$$${line}<br>";\
	done > $(pdir)/$(1).files.html
	touch $(call make_stamp,$(1))


endef


define get_build_dep
$(filter-out $(dummies),$(shell source $(1)/ABUILD; echo $$build_deps))
endef

dirs = $(patsubst ./%,%,$(shell find . -type d -maxdepth 1))
dirs := $(filter-out $(exclude), $(dirs))
$(info processing: $(dirs))

indexfiles=index.log package_list setup_variants.list package_list.html packages.xml.* 

 

all: $(dirs) index

.PHONY: purge pushindex $(dirs) all

genhtml: index
	cat $(pdir)/package_list|while read line;\
	do echo "$$line<br>";\
	done  > $(pdir)/package_list.html

pushindex: genhtml
	cd $(pdir);\
	scp $(indexfiles) $(repo)

push: 
	rsync -arv --delete-after $(pdir) $(repo)

purge:
	mpkg remove $(dirs)
	-rm -f $(pdir)/*
	-rm -f $(stampdir)/*

$(foreach dir,$(dirs),$(eval $(call package,$(dir),$(call get_build_dep,$(dir)))))
# $(foreach dummy,$(dumies),$(eval $(call dummy_rule,$(dummy))))

index:
	cd $(pdir) && mpkg-index

