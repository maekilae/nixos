#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_step() { echo -e "${BLUE}==>${NC} $1"; }

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Do not run this script as root!"
    exit 1
fi

# Default values
UPGRADE=false
BUILD_CMD="switch"
HOSTNAME=$(hostname)
IMPURE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--upgrade)
            UPGRADE=true
            shift
            ;;
        -b|--boot)
            BUILD_CMD="boot"
            shift
            ;;
        -t|--test)
            BUILD_CMD="test"
            shift
            ;;
        -h|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -i|--impure)
            IMPURE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -u, --upgrade         Update all flake inputs before rebuilding"
            echo "  -b, --boot            Build and activate on next boot (instead of switch)"
            echo "  -t, --test            Build and activate temporarily (until reboot)"
            echo "  -h, --hostname NAME   Specify hostname (default: current hostname)"
            echo "  -i, --impure          Allow impure evaluation (access environment variables, etc.)"
            echo "      --help            Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Show git status
if git rev-parse --git-dir > /dev/null 2>&1; then
    print_step "Git status:"
    git status --short
    echo ""
fi

# Upgrade flake inputs if requested
if [ "$UPGRADE" = true ]; then
    print_step "Upgrading flake inputs..."
    nix flake update
    print_info "Flake inputs upgraded!"
    echo ""
fi

# Build the system
if [ "$(uname -s)" = "Darwin" ]; then
    # nix-darwin: only `switch` is meaningful; boot/test are NixOS-only.
    DARWIN_CMD="$BUILD_CMD"
    if [ "$BUILD_CMD" = "boot" ] || [ "$BUILD_CMD" = "test" ]; then
        print_warn "'${BUILD_CMD}' is not supported on Darwin; using 'switch' instead"
        DARWIN_CMD="switch"
    fi

    REBUILD_ARGS="${DARWIN_CMD} --flake .#${HOSTNAME}"
    if [ "$IMPURE" = true ]; then
        REBUILD_ARGS="${REBUILD_ARGS} --impure"
        print_warn "Building with --impure flag"
    fi

    print_step "Rebuilding nix-darwin configuration (${DARWIN_CMD})..."
    if command -v darwin-rebuild > /dev/null 2>&1; then
        sudo darwin-rebuild ${REBUILD_ARGS}
    else
        print_warn "darwin-rebuild not found — bootstrapping nix-darwin for the first time"
        sudo nix run nix-darwin -- ${REBUILD_ARGS}
    fi

    echo ""
    print_info "Build completed successfully!"
    print_warn "You may need to open a new shell for all changes to take effect."
else
    REBUILD_ARGS="${BUILD_CMD} --flake .#${HOSTNAME}"
    if [ "$IMPURE" = true ]; then
        REBUILD_ARGS="${REBUILD_ARGS} --impure"
        print_warn "Building with --impure flag"
    fi

    print_step "Rebuilding NixOS configuration (${BUILD_CMD})..."
    sudo nixos-rebuild ${REBUILD_ARGS}

    echo ""
    print_info "Build completed successfully!"

    if [ "$BUILD_CMD" = "boot" ]; then
        print_warn "Changes will take effect on next boot."
    elif [ "$BUILD_CMD" = "test" ]; then
        print_warn "Changes are temporary and will revert on reboot."
    else
        print_warn "You may need to log out and back in for all changes to take effect."
    fi
fi
