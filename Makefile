CLANG		 	:= clang
LLD				:= ld.lld
OBJCOPY			:= llvm-objcopy

BUILD_DIR = build
SRC_DIR = src

BD = $(BUILD_DIR)
SD = $(SRC_DIR)

TARGET_TRIPLE 	?= aarch64-none-elf

CLANG_OPS := -Wall -nostdlib -ffreestanding -mgeneral-regs-only -Iinclude -mcpu=cortex-a72+nosimd --target=${TARGET_TRIPLE} -MMD -O0 -g
ASM_OPS := $(CLANG_OPS)
C_OPS := $(CLANG_OPS)

ifndef VERBOSE
    VERB := @
endif

.PHONY: all clean qemu qemu-debug
.SUFFIXES:

$(BD)/%_c.o: $(SD)/%.c
	$(VERB) echo Compiling $<
	$(VERB) mkdir -p $(@D)
	$(VERB) $(CLANG) $(C_OPS) -c $< -o $@

$(BD)/%_s.o: $(SD)/%.S
	$(VERB) echo Compiling $<
	$(VERB) mkdir -p $(@D)
	$(VERB) $(CLANG) $(ASM_OPS) -c $< -o $@

$(BD)/%.elf:
	$(VERB) echo Linking $@
	$(VERB) $(LLD) -o $@ $(filter %.o,$^) $(patsubst %,-T %,$(filter %.ld,$^))

$(BD)/kernel8.elf: $(BD)/boot_s.o $(BD)/main_c.o $(SD)/linker.ld $(BD)/mm_s.o $(BD)/utils_s.o $(BD)/dtb_c.o $(BD)/endian_s.o

$(BD)/%.img: $(BD)/%.elf
	$(VERB) echo Creating kernel8.img
	$(VERB) $(OBJCOPY) $< -O binary $@

clean:
	$(VERB) rm -rf $(BD)

$(BD)/KusOS.img: $(BD)/kernel8.img src/config.txt third-party/raspi-firmware/boot/*
	$(VERB) echo Building the image

	$(VERB) echo -- Making the image file \($(BD)/KusOS.img\)
	$(VERB) dd if=/dev/zero of=$(BD)/tmp.img count=64 bs=1M
	$(VERB) echo -e "unit: sectors\n/dev/hdc1 : Id=0c" | sfdisk $(BD)/tmp.img > /dev/null
	$(VERB) mkfs.vfat -F 32 $(BD)/tmp.img > /dev/null

	$(VERB) echo -- Copying files to $(BD)/staging
	$(VERB) mkdir -p $(BD)/staging
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-3-b.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-3-b-plus.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2710-rpi-cm3.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-400.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-cm4.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bcm2711-rpi-cm4s.dtb $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/*.dat $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/*.elf $(BD)/staging/
	$(VERB) cp third-party/raspi-firmware/boot/bootcode.bin $(BD)/staging/
	$(VERB) cp src/config.txt $(BD)/staging/
	$(VERB) cp $(BD)/kernel8.img $(BD)/staging/kernel8.img

	$(VERB) echo -- Gzipping the kernel
	$(VERB) gzip $(BD)/staging/kernel8.img
	$(VERB) mv $(BD)/staging/kernel8.img.gz $(BD)/staging/kernel8.img

	$(VERB) echo -- Copying files into the image
	$(VERB) mcopy -i $(BD)/tmp.img $(BD)/staging/* ::/

	$(VERB) mv $(BD)/tmp.img $(BD)/KusOS.img
	$(VERB) echo Done!

qemu: $(BD)/kernel8.img third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb
	$(VERB) qemu-system-aarch64 -machine raspi4 -kernel $(BD)/kernel8.img -dtb third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb

qemu-debug: $(BD)/kernel8.img third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb
	$(VERB) qemu-system-aarch64 -machine raspi4 -kernel $(BD)/kernel8.img -dtb third-party/raspi-firmware/boot/bcm2711-rpi-4-b.dtb -S -s

all: $(BD)/kernel8.img
