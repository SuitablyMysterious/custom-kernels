#!/usr/bin/env bash

set -euo pipefail

PHASE=${1:?need phase: autofdo|propeller|bolt}
ARCH=${2:?need arch e.g. x86-64-v3}
shift 2
[[ "${1:-}" == "--" ]] && shift
CMD=("$@")
[[ ${#CMD[@]} -eq 0 ]] && { echo "need a command to profile"; exit 1; }

if ! command -v perf &>/dev/null; then
    echo "perf not found"
    exit 1
fi

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT="$REPO_ROOT/profiles/machines/$ARCH/raw"
mkdir -p "$OUT"

case "$PHASE" in
    autofdo)
        perf record -e cycles -j any,k -a -o "$OUT/perf_autofdo.data" -- "${CMD[@]}"
        ;;
    propeller)
        perf record -e cycles -b -a -o "$OUT/perf_propeller.data" -- "${CMD[@]}"
        ;;
    bolt)
        perf record -e cycles -b -a -o "$OUT/perf_bolt.data" -- "${CMD[@]}"
        ;;
    *)
        echo "unknown phase: $PHASE"
        exit 1
        ;;
esac

echo "saved to $OUT"
