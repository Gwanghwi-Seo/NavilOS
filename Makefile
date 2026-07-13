ARCH = armv7-a
MCPU = cortex-a8

TARGET = rvpb

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy
BEAR = bear

LINKER_SCRIPT = navilos.ld
MAP_FILE = build/navilos.map

SRC_DIRS = boot \
		   hal/$(TARGET) \
		   lib \
		   kernel

INC_DIRS = include \
		   hal \
		   hal/$(TARGET) \
		   lib \
		   kernel

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

VPATH = $(SRC_DIRS)

C_SRC_PATHS = $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
C_SRCS = $(notdir $(C_SRC_PATHS))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))

CPPFLAGS = $(addprefix -I ,$(INC_DIRS))

CFLAGS = -c -g -std=c11 -ffreestanding
LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

navilos = build/navilos.axf
navilos_bin = build/navilos.bin

.PHONY: all clean run debug gdb setup compile_commands

all: $(navilos)

clean:
	@rm -fr build

setup:
	./scripts/setup.sh

compile_commands:
	$(BEAR) -- $(MAKE) clean all

run: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -nographic

debug: $(navilos)
	qemu-system-arm -M realview-pb-a8 -kernel $(navilos) -S -gdb tcp::1234,ipv4 &

gdb:
	gdb

$(navilos): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(navilos) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(navilos) $(navilos_bin)

build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -mcpu=$(MCPU) $(CPPFLAGS) $(CFLAGS) -o $@ $<

build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -mcpu=$(MCPU) $(CPPFLAGS) $(CFLAGS) -o $@ $<

