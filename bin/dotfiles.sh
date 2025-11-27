#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

_show_usage() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
    install                     Install all dotfiles and dependencies
    update                      Update installed tools and dependencies
    system-update               Update system packages only
    link [package1 package2...] Link dotfiles with stow (all or specific packages)
    unlink [package1 package2...] Unlink dotfiles with stow (all or specific packages)

OS Detection:
    Detected OS: $(_detect_os)

EOF
}

main() {
    local os=$(_detect_os)
    local command="${1:-}"
    shift || true
    
    if [[ -z "$command" ]]; then
        _show_usage
        exit 1
    fi
    
    case "$os" in
        macos)
            "${SCRIPT_DIR}/lib/macos.sh" "$command" "$@"
            ;;
        arch)
            "${SCRIPT_DIR}/lib/arch.sh" "$command" "$@"
            ;;
        ubuntu)
            "${SCRIPT_DIR}/lib/ubuntu.sh" "$command" "$@"
            ;;
        unknown)
            echo "Error: Unsupported operating system"
            echo "Please run the platform-specific script directly:"
            echo "  ${SCRIPT_DIR}/lib/macos.sh"
            echo "  ${SCRIPT_DIR}/lib/arch.sh"
            echo "  ${SCRIPT_DIR}/lib/ubuntu.sh"
            exit 1
            ;;
    esac
}

main "$@"
