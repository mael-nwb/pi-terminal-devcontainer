#!/bin/sh
set -eu

PI_INSTALLER_URL="https://pi.dev/install.sh"
NODE_DIST_URL="https://nodejs.org/dist/latest-v22.x"
NODE_INSTALL_DIR="/usr/local/lib/pi-node"
readonly PI_INSTALLER_URL NODE_DIST_URL NODE_INSTALL_DIR

main() {
    echo "Activating feature 'pi-cli'"

    require_command curl
    require_command tar
    ensure_node_runtime
    install_pi
    expose_pi_command

    if command -v pi >/dev/null 2>&1; then
        pi --version || true
        return 0
    fi

    echo "ERROR: Pi CLI installation failed: pi command not found" >&2
    return 1
}

require_command() {
    command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        return 0
    fi

    echo "ERROR: Required command not found: $command_name" >&2
    return 1
}

ensure_node_runtime() {
    if node_runtime_is_supported; then
        return 0
    fi

    install_standalone_node
    export PATH="$NODE_INSTALL_DIR/current/bin:$PATH"

    if node_runtime_is_supported; then
        return 0
    fi

    echo "ERROR: Node.js 22.19.0 or newer with npm is required to install Pi" >&2
    return 1
}

node_runtime_is_supported() {
    if ! command -v node >/dev/null 2>&1; then
        return 1
    fi

    if ! command -v npm >/dev/null 2>&1; then
        return 1
    fi

    node -e 'const [major, minor, patch] = process.versions.node.split(".").map(Number); process.exit(major > 22 || (major === 22 && (minor > 19 || (minor === 19 && patch >= 0))) ? 0 : 1)' >/dev/null 2>&1
}

install_standalone_node() {
    node_platform="$(detect_node_platform)"
    node_arch="$(detect_node_arch)"
    node_tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/pi-node.XXXXXX")"
    checksum_file="$node_tmp_dir/SHASUMS256.txt"

    ensure_xz_support

    curl -fsSL "$NODE_DIST_URL/SHASUMS256.txt" -o "$checksum_file"
    node_file="$(find_node_archive "$checksum_file" "$node_platform" "$node_arch")"

    if [ -z "$node_file" ]; then
        echo "ERROR: No Node.js archive found for ${node_platform}-${node_arch}" >&2
        return 1
    fi

    mkdir -p "$NODE_INSTALL_DIR"
    curl -fsSL "$NODE_DIST_URL/$node_file" -o "$node_tmp_dir/$node_file"
    verify_node_archive "$node_tmp_dir" "$node_file"
    tar -xf "$node_tmp_dir/$node_file" -C "$NODE_INSTALL_DIR"
    ln -sfn "$NODE_INSTALL_DIR/${node_file%.tar.xz}" "$NODE_INSTALL_DIR/current"
    ln -sfn "$NODE_INSTALL_DIR/current/bin/node" /usr/local/bin/node
    ln -sfn "$NODE_INSTALL_DIR/current/bin/npm" /usr/local/bin/npm
    ln -sfn "$NODE_INSTALL_DIR/current/bin/npx" /usr/local/bin/npx
    rm -rf "$node_tmp_dir"
}

detect_node_platform() {
    case "$(uname -s)" in
        Linux) echo "linux" ;;
        Darwin) echo "darwin" ;;
        *)
            echo "ERROR: Unsupported operating system: $(uname -s)" >&2
            return 1
            ;;
    esac
}

detect_node_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x64" ;;
        arm64|aarch64) echo "arm64" ;;
        armv7l) echo "armv7l" ;;
        *)
            echo "ERROR: Unsupported CPU architecture: $(uname -m)" >&2
            return 1
            ;;
    esac
}

ensure_xz_support() {
    if command -v xz >/dev/null 2>&1; then
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        apt-get install -y --no-install-recommends xz-utils
        return 0
    fi

    if command -v apk >/dev/null 2>&1; then
        apk add --no-cache xz
        return 0
    fi

    echo "ERROR: xz is required to extract the Node.js archive" >&2
    return 1
}

find_node_archive() {
    checksum_file="$1"
    node_platform="$2"
    node_arch="$3"

    awk -v suffix="-$node_platform-$node_arch.tar.xz" '
        index($2, "node-v") == 1 && substr($2, length($2) - length(suffix) + 1) == suffix { print $2; exit }
    ' "$checksum_file"
}

verify_node_archive() {
    node_tmp_dir="$1"
    node_file="$2"
    selected_checksum_file="$node_tmp_dir/SHASUMS256.selected"

    awk -v file="$node_file" '$2 == file { print }' "$node_tmp_dir/SHASUMS256.txt" > "$selected_checksum_file"

    if command -v sha256sum >/dev/null 2>&1; then
        (cd "$node_tmp_dir" && sha256sum -c "$(basename "$selected_checksum_file")")
        return 0
    fi

    if command -v shasum >/dev/null 2>&1; then
        (cd "$node_tmp_dir" && shasum -a 256 -c "$(basename "$selected_checksum_file")")
        return 0
    fi

    echo "ERROR: No SHA-256 checksum tool found" >&2
    return 1
}

install_pi() {
    curl -fsSL "$PI_INSTALLER_URL" | sh
}

expose_pi_command() {
    pi_path="$(command -v pi 2>/dev/null || true)"

    if [ -z "$pi_path" ]; then
        pi_path="$NODE_INSTALL_DIR/current/bin/pi"
    fi

    if [ ! -e "$pi_path" ]; then
        echo "ERROR: Pi CLI installation failed: pi command not found" >&2
        return 1
    fi

    ln -sfn "$pi_path" /usr/local/bin/pi
}

main "$@"
