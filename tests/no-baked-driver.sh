#!/usr/bin/env bash
# tests/no-baked-driver.sh — the executable control for the SHIPPED absence predicate.
#
# It EXTRACTS the `cuda-no-baked-driver` step body from charly.yml and runs it against a synthetic
# layout, so a revert of the predicate (e.g. back to `[ -e "$d/vdpau" ]`) FAILS this test:
#   - a clean vdpau tree (the generic libvdpau's libvdpau_trace.so, pulled by ffmpeg) must PASS;
#   - a planted libvdpau_nvidia.so.1 must RED.
# The step takes CUDA_LIB_DIRS / CUDA_BIN_DIRS so it can run against a fixture. A copied predicate
# would not catch a revert; extracting the real body is the point (opencharly/layer-cuda#42).
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/lib/vdpau" "$tmp/bin"
: > "$tmp/lib/vdpau/libvdpau_trace.so"

body() {
  awk '
    /^              id: cuda-no-baked-driver$/ { found=1 }
    found && /^              command: \|$/ { cap=1; next }
    cap && /^                / { sub(/^                /,""); print; next }
    cap { exit }
  ' "$root/charly.yml"
}

run() { CUDA_LIB_DIRS="$tmp/lib" CUDA_BIN_DIRS="$tmp/bin" bash -c "$(body)" >/dev/null 2>&1; }

run || { echo "FAIL: the shipped predicate reds a clean tree"; exit 1; }
: > "$tmp/lib/vdpau/libvdpau_nvidia.so.1"
if run; then echo "FAIL: the shipped predicate passes a planted libvdpau_nvidia"; exit 1; fi
echo "no-baked-driver: the SHIPPED predicate passes a clean tree and reds a planted libvdpau_nvidia"
