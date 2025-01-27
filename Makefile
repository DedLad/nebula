BUILD_DIR = build
KERNEL_DIR = kernel
BOOTLOADER_DIR = bootloader

ASM = nasm
RUSTC = cargo
LD = ld.lld
OBJCOPY = llvm-objcopy
QEMU = qemu-system-x86_64

ASM_FLAGS = -f bin
QEMU_FLAGS = -machine q35 -drive format=raw,file=$(OS_IMAGE)

MBR_BIN = $(BUILD_DIR)/mbr.bin
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
OS_IMAGE = $(BUILD_DIR)/os.img

.PHONY: all clean run

all: $(OS_IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(MBR_BIN): $(BOOTLOADER_DIR)/*.asm
	$(ASM) $(ASM_FLAGS) -o $@ $(BOOTLOADER_DIR)/mbr.asm

$(KERNEL_ELF): 
	cd $(KERNEL_DIR) && $(RUSTC) build --release --target x86_64-unknown-none
	cp $(KERNEL_DIR)/target/x86_64-unknown-none/release/kernel $@

$(OS_IMAGE): $(BUILD_DIR) $(MBR_BIN) $(KERNEL_ELF)
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=$(MBR_BIN) of=$@ conv=notrunc
	dd if=$(KERNEL_ELF) of=$@ conv=notrunc seek=1

run: $(OS_IMAGE)
	$(QEMU) $(QEMU_FLAGS)

clean:
	rm -rf $(BUILD_DIR)
	cd $(KERNEL_DIR) && cargo clean