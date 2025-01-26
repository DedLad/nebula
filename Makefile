# Paths

BUILD_DIR = $(CURDIR)/build

KERNEL_DIR = $(CURDIR)/kernel

BOOTLOADER_DIR = $(CURDIR)/bootloader

LINKER_SCRIPT = $(CURDIR)/linker.ld

ASM = nasm

RUSTC = cargo

LD = ld.lld



ASM_FLAGS = -f bin -g

LD_FLAGS = 



# Target files

MBR_BIN = $(BUILD_DIR)/mbr.bin

KERNEL_BIN = $(BUILD_DIR)/kernel.bin

KERNEL_ENTRY_BIN = $(BUILD_DIR)/kernel-entry.bin

OS_IMAGE = $(BUILD_DIR)/os_image.bin



# Default target

all: $(OS_IMAGE)



# Create build directory if it doesn't exist

$(BUILD_DIR):

	mkdir -p $(BUILD_DIR)



# Assemble MBR as binary

$(MBR_BIN): $(BOOTLOADER_DIR)/mbr.asm

	$(ASM) -f bin -o $@ $(BOOTLOADER_DIR)/mbr.asm



# Assemble kernel-entry.asm (32-bit)

$(KERNEL_ENTRY_BIN): $(BOOTLOADER_DIR)/kernel-entry.asm

	$(ASM) -f elf32 -o $@ $(BOOTLOADER_DIR)/kernel-entry.asm



# Build the kernel using cargo (Rust)

$(KERNEL_BIN): $(KERNEL_DIR)

	cd $(KERNEL_DIR) && cargo build --target x86_64-unknown-none.json --release

	cp $(KERNEL_DIR)/target/x86_64-unknown-none/release/kernel $(BUILD_DIR)/kernel.elf

	objcopy -O binary $(BUILD_DIR)/kernel.elf $(KERNEL_BIN)



# Link everything into a single OS image by concatenation

$(OS_IMAGE): $(BUILD_DIR) $(MBR_BIN) $(KERNEL_BIN)

	cat $(MBR_BIN) $(KERNEL_BIN) > $@



# Run in QEMU

run: $(OS_IMAGE)

	$(QEMU) -drive format=raw,file=$(OS_IMAGE),if=floppy



# Clean build files

clean:

	rm -rf $(BUILD_DIR)

	cd $(KERNEL_DIR) && cargo clean



.PHONY: all clean run