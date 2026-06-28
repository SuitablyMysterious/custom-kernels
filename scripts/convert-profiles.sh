#!/usr/bin/env bash
# convert-profiles.sh <autofdo|propeller|bolt|all> <arch> <vmlinux>


set -euo pipefail

PHASE=${1:?need phase: autofdo|propeller|bolt|all}
ARCH=${2:?need arch e.g. x86-64-v3}
VMLINUX=${3:?need path to vmlinux}

LLVM_BIN=~/dev/build/bin
PROPELLER_BIN=~/llvm-propeller/build/propeller

need() {
    [ -x "$1" ] || { echo "not found: $1"; exit 1; }
}

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RAW="$REPO_ROOT/profiles/machines/$ARCH/raw"
OUT="$REPO_ROOT/profiles/machines/$ARCH"

do_autofdo() {
    need "$LLVM_BIN/llvm-profgen"
    "$LLVM_BIN/llvm-profgen" \
        --kernel \
        --binary="$VMLINUX" \
        --perfdata="$RAW/perf_autofdo.data" \
        --output="$OUT/kernel.afdo"
}

do_propeller() {
    need "$PROPELLER_BIN/generate_propeller_profiles"
    "$PROPELLER_BIN/generate_propeller_profiles" \
        --binary="$VMLINUX" \
        --profile="$RAW/perf_propeller.data" \
        --profile_type=PERF_LBR \
        --cc_profile="$OUT/propeller_cc_profile.txt" \
        --ld_profile="$OUT/propeller_ld_profile.txt"
}

do_bolt() {
    need "$LLVM_BIN/perf2bolt"
    "$LLVM_BIN/perf2bolt" \
        -p "$RAW/perf_bolt.data" \
        -o "$OUT/perf_overall.fdata" \
        "$VMLINUX"
}

case "$PHASE" in
    autofdo)   do_autofdo ;;
    propeller) do_propeller ;;
    bolt)      do_bolt ;;
    all)       do_autofdo; do_propeller; do_bolt ;;
    *)         echo "unknown phase: $PHASE"; exit 1 ;;
esac
