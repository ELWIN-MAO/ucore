ifndef ARCH
$(error ARCH is not set. Use 'board' to set it after 'source scripts/envsetup.sh')
endif
ifndef BOARD
$(error BOARD is not set. Use 'board' to set it after 'source scripts/envsetup.sh')
endif

pwd := $(shell pwd)
build-dir := $(pwd)/out/build-$(ARCH)-$(BOARD)

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

rootfs: | $(kernel-config)
	@make -C $(pwd)/kernel/ucore O=$(kernel-build-dir) sfsimg


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


.PHONY: all help kernel-config kernel rootfs clean
