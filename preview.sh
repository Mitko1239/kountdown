#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$project_dir/package"

cleanup() {
    kill "$panel_pid" "$popup_pid" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

plasmoidviewer \
    --applet "$package_dir" \
    --formfactor horizontal \
    --location bottomedge &
panel_pid=$!

plasmoidviewer \
    --applet "$package_dir" \
    --formfactor application \
    --size 500x300 &
popup_pid=$!

wait
