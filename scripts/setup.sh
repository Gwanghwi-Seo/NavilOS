#!/usr/bin/env sh

set -eu

PROJECT_NAME="NavilOS"

info() {
    printf '%s\n' "[$PROJECT_NAME] $*"
}

warn() {
    printf '%s\n' "[$PROJECT_NAME] warning: $*" >&2
}

fail() {
    printf '%s\n' "[$PROJECT_NAME] error: $*" >&2
    exit 1
}

has_command() {
    command -v "$1" >/dev/null 2>&1
}

sudo_cmd() {
    if [ "$(id -u)" -eq 0 ]; then
        printf '%s' ""
    elif has_command sudo; then
        printf '%s' "sudo"
    else
        fail "sudo is required to install packages on this system"
    fi
}

install_ubuntu_debian() {
    SUDO="$(sudo_cmd)"

    info "Detected apt-based Linux"
    info "Installing ARM toolchain, QEMU, make, Bear, and GDB support"

    if [ -n "$SUDO" ]; then
        $SUDO apt-get update
        $SUDO apt-get install -y \
            bear \
            gcc-arm-none-eabi \
            gdb-multiarch \
            make \
            qemu-system-arm
    else
        apt-get update
        apt-get install -y \
            bear \
            gcc-arm-none-eabi \
            gdb-multiarch \
            make \
            qemu-system-arm
    fi
}

install_macos() {
    info "Detected macOS"

    if ! has_command brew; then
        fail "Homebrew is not installed. Install it first: https://brew.sh"
    fi

    info "Installing ARM toolchain, QEMU, make, Bear, and GDB support"
    brew install \
        arm-none-eabi-gcc \
        bear \
        gdb \
        make \
        qemu
}

verify_command() {
    if has_command "$1"; then
        info "Found $1"
    else
        fail "$1 was not found in PATH"
    fi
}

verify_gdb() {
    if has_command arm-none-eabi-gdb; then
        info "Found arm-none-eabi-gdb"
    elif has_command gdb-multiarch; then
        info "Found gdb-multiarch"
    elif has_command gdb; then
        warn "Found gdb, but arm-none-eabi-gdb or gdb-multiarch is preferred for ARM debugging"
    else
        warn "No GDB found. Install arm-none-eabi-gdb, gdb-multiarch, or gdb for remote debugging"
    fi
}

verify_tools() {
    info "Verifying required tools"
    verify_command arm-none-eabi-gcc
    verify_command arm-none-eabi-objcopy
    verify_command qemu-system-arm
    verify_command make
    verify_command bear
    verify_gdb
}

print_next_steps() {
    info "For Cursor/clangd IDE support, run: make compile_commands"
    info "compile_commands.json is generated locally and ignored by Git"
}

main() {
    case "$(uname -s)" in
        Darwin)
            install_macos
            ;;
        Linux)
            if has_command apt-get; then
                install_ubuntu_debian
            else
                fail "unsupported Linux package manager. This script currently supports apt-based distributions"
            fi
            ;;
        *)
            fail "unsupported OS: $(uname -s)"
            ;;
    esac

    verify_tools
    print_next_steps
    info "Setup complete"
}

main "$@"
