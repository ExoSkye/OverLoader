CLANG		 	:= clang
LLD				:= ld.lld
OBJCOPY			:= llvm-objcopy

BUILD_DIR = build
SRC_DIR = src

BD = $(BUILD_DIR)
SD = $(SRC_DIR)

TARGET_TRIPLE 	?= aarch64-none-elf

CLANG_OPS := -Wall -nostdlib -ffreestanding -mgeneral-regs-only -Iinclude -mcpu=cortex-a72+nosimd --target=${TARGET_TRIPLE} -MMD
ASM_OPS := $(CLANG_OPS)
C_OPS := $(CLANG_OPS)

ifndef VERBOSE
    VERB := @
endif

.PHONY: all clean
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

$(BD)/kernel8.elf: $(BD)/boot_s.o $(BD)/main_c.o $(SD)/linker.ld $(BD)/mm_s.o $(BD)/utils_s.o

$(BD)/%.img: $(BD)/%.elf
	$(VERB) echo Creating kernel8.img
	$(VERB) $(OBJCOPY) $< -O binary $@

clean:
	$(VERB) rm -rf $(BD)



all: $(BD)/kernel8.img