This project is based on the "Embedded OS development project" for the ARM architecture

## Build And Debug Guide

### Prerequisites

Install the required tools with the setup script.

```sh
make setup
```

This script supports:

```text
Ubuntu / Debian  apt
macOS            Homebrew
```

It installs the ARM cross compiler, QEMU, make, and GDB support where available.

Manual installation commands are also shown below.

Ubuntu / Debian:

```sh
sudo apt-get update
sudo apt-get install -y gcc-arm-none-eabi gdb-multiarch make qemu-system-arm
```

macOS:

```sh
brew install arm-none-eabi-gcc gdb make qemu
```

After installation, these commands should be available.

```sh
arm-none-eabi-gcc
make
qemu-system-arm
gdb
```

For GDB, `arm-none-eabi-gdb` or `gdb-multiarch` is usually easier to use than a host-only GDB because this project targets ARM.

### Project Target

The current `Makefile` builds an ARMv7-A image for QEMU RealView PB-A8.

```make
ARCH = armv7-a
MCPU = cortex-a8
TARGET = rvpb
```

The linker script is `navilos.ld`, and the final image starts at address `0x0`.

### Clean

Remove all generated build files.

```sh
make clean
```

This deletes the `build/` directory.

### Compile And Build

Build the whole project.

```sh
make
```

This is the same as:

```sh
make all
```

The build creates these files:

```text
build/navilos.axf  # ELF executable with debug symbols
build/navilos.bin  # raw binary image
build/navilos.map  # linker map file
```

Source files are collected from:

```text
boot/*.S
boot/*.c
hal/rvpb/*.c
lib/*.c
```

Include paths are:

```text
include/
hal/
hal/rvpb/
lib/
```

### Run In QEMU

Run the OS image in QEMU.

```sh
make run
```

Internally this runs:

```sh
qemu-system-arm -M realview-pb-a8 -kernel build/navilos.axf -nographic
```

Useful notes:

- `-M realview-pb-a8` selects the ARM RealView PB-A8 board.
- `-kernel build/navilos.axf` loads the ELF image.
- `-nographic` uses the terminal as the serial console.
- To quit QEMU in `-nographic` mode, press `Ctrl-a` then `x`.

### Start QEMU For GDB

Start QEMU in debug mode.

```sh
make debug
```

Internally this runs:

```sh
qemu-system-arm -M realview-pb-a8 -kernel build/navilos.axf -S -gdb tcp::1234,ipv4 &
```

Important flags:

- `-S` starts QEMU paused before executing the first instruction.
- `-gdb tcp::1234,ipv4` opens a GDB remote debugging server on port `1234`.
- `&` runs QEMU in the background.

### Connect With GDB

Open another terminal and start GDB with the ELF file.

```sh
arm-none-eabi-gdb build/navilos.axf
```

If you only have `gdb-multiarch`, use:

```sh
gdb-multiarch build/navilos.axf
```

If you use the Makefile target:

```sh
make gdb
```

then load the ELF manually inside GDB:

```gdb
file build/navilos.axf
```

Connect to QEMU:

```gdb
target remote localhost:1234
```

Now QEMU is paused and GDB controls execution.

### Common GDB Commands

Set breakpoints:

```gdb
break main
break vector_start
break Irq_Handler
```

Run or continue execution:

```gdb
continue
```

Step one source line:

```gdb
step
next
```

Step one CPU instruction:

```gdb
stepi
nexti
```

Inspect registers:

```gdb
info registers
info registers pc sp lr cpsr
```

Show instructions near the current program counter:

```gdb
x/10i $pc
```

Disassemble a function:

```gdb
disassemble main
disassemble reset_handler
```

Inspect memory:

```gdb
x/16wx 0x0
x/16wx $sp
```

Show backtrace:

```gdb
backtrace
```

Quit GDB:

```gdb
detach
quit
```

### Typical Debug Session

Terminal 1:

```sh
make clean
make
make debug
```

Terminal 2:

```sh
arm-none-eabi-gdb build/navilos.axf
```

Inside GDB:

```gdb
target remote localhost:1234
break main
continue
info registers
x/10i $pc
next
```

This flow starts QEMU paused at boot, connects GDB, breaks at `main`, and then lets you inspect registers, instructions, and source-level execution.

