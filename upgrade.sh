#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

cd "$project_dir"
kpackagetool6 --type Plasma/Applet --upgrade package

if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet plasma-plasmashell.service; then
    systemctl --user restart plasma-plasmashell.service
else
    kquitapp6 plasmashell
    kstart plasmashell
fi
