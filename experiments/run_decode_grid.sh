#!/usr/bin/env bash
# Compatibility entrypoint; use experiments/mi300x/run_decode_grid.sh.
set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/mi300x/run_decode_grid.sh" "$@"
