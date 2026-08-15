#!/usr/bin/env bash
# Compatibility entrypoint; use experiments/mi300x/profile_steady_rocm.sh.
set -euo pipefail

exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/mi300x/profile_steady_rocm.sh" "$@"
