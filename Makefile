ifndef ARCH
$(error ARCH is not set. Use 'board' to set it after 'source scripts/envsetup.sh')
endif
ifndef BOARD
$(error BOARD is not set. Use 'board' to set it after 'source scripts/envsetup.sh')
endif

pwd := $(shell pwd)
build-dir := $(pwd)/out/build-$(ARCH)-$(BOARD)

-include $(build-dir)/.component-config

all: rootfs kernel

# Kernel
# ==================================================

kernel-src-dir := $(pwd)/kernel/ucore
kernel-build-dir := $(build-dir)/kernel
kernel-config := $(kernel-build-dir)/config/auto.conf

$(kernel-config):
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) defconfig

kernel-config:
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) defconfig

kernel-menuconfig:
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) menuconfig

kernel: | $(kernel-config)
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) kernel
	@if [ `grep "SWAP=y" $(kernel-build-dir)/.config` ]; then		\
		make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) swapimg;	\
	fi

# Root FS
# ==================================================

root-fs-dir := $(build-dir)/rootfs
image := $(kernel-build-dir)/sfs.img
component-script := $(pwd)/scripts/component.sh

define component_template =
  $(1): | $(root-fs-dir)
	@make -C $(pwd)/$(1)
  $(1)-install: $(1)
	@$(component-script) $(1) install

  component-targets += $(1) $(1)-install
  ifeq ($$(COMPONENT_$(subst /,_,$(1))), y)
    components += $(1)-install
  endif
endef

$(foreach comp,$(wildcard lib/*),$(eval $(call component_template,$(comp))))

$(kernel-build-dir)/mksfs: | $(kernel-config)
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) $(shell realpath $(kernel-build-dir))/mksfs

$(build-dir)/rootfs:
	@mkdir -p $@
	@make -C $(kernel-src-dir)/src/user-ucore initial_dir
	-cp -r $(kernel-src-dir)/src/user-ucore/_initial/* $@

userapp: | $(kernel-config) $(root-fs-dir)
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) userlib
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) userapp
	@mkdir -p $(root-fs-dir)/bin
	@$(component-script) install $(kernel-build-dir)/user-ucore/bin $(root-fs-dir)/bin
	@mkdir -p $(root-fs-dir)/testbin
	@$(component-script) install $(kernel-build-dir)/user-ucore/testbin $(root-fs-dir)/testbin

rootfs: $(kernel-build-dir)/mksfs userapp $(components) | $(kernel-config)
	@dd if=/dev/zero of=$(image) bs=1M count=$(shell grep "SFS_IMAGE_SIZE" $(kernel-build-dir)/.config | grep -o "[0-9]*")
	@$(kernel-build-dir)/mksfs $(image) $(root-fs-dir)

# Running
# ==================================================

run-script := $(kernel-src-dir)/uCore_run

run:
	@$(run-script) -d $(kernel-build-dir)

# Cleaning
# ==================================================

clean:
	@rm -rf $(kernel-build-dir)

clean-all:
	@rm -rf out
	@rm -rf build


.PHONY: all help kernel-config kernel rootfs clean $(component-targets)
