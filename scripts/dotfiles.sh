#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Usage/error messages from lib/<os>.sh name this script (see lib/common.sh)
export DOTFILES_SCRIPT="$0"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

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
    _dotfiles_usage
    cat << EOF

OS Detection:
    Detected OS: $(_detect_os)

EOF
}

main() {
    local os
    os=$(_detect_os)
    local command="${1:-}"
    shift || true
    
    if [[ -z "$command" ]]; then
        _show_usage
        exit 1
    fi

    # OS-independent commands
    if [[ "$command" == "check-links" || "$command" == "mise" ]]; then
        _dotfiles_main "$command" "$@"
        exit $?
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
