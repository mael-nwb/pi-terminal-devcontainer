#!/bin/sh
set -eu

main() {
    echo "Activating feature 'pi-cli'"

    if ! command -v node >/dev/null 2>&1; then
        echo "ERROR: Node.js is required before installing Pi. Ensure the node devcontainer feature dependency ran successfully." >&2
        return 1
    fi

    if ! command -v npm >/dev/null 2>&1; then
        echo "ERROR: npm is required before installing Pi. Ensure the node devcontainer feature dependency ran successfully." >&2
        return 1
    fi

    npm install -g --ignore-scripts @earendil-works/pi-coding-agent

    if command -v pi >/dev/null 2>&1; then
        pi --version || true
        return 0
    fi

    echo "ERROR: Pi CLI installation failed: pi command not found" >&2
    return 1
}

main "$@"
