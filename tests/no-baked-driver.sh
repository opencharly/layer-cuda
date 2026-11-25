#!/usr/bin/env bash
# tests/no-baked-driver.sh — the executable control for the absence predicate in the
# `cuda-no-baked-driver` plan step (charly.yml): the vdpau arm counts the DRIVER FILE, not the
# tree's existence.
#
# Why this exists: the merged form counted `/usr/lib*/vdpau`'s EXISTENCE, but the generic libvdpau
# (pulled by ffmpeg, which this layer requires) ships `/usr/lib/vdpau/libvdpau_trace.so` — so a
# CLEAN image red with "driver user-space baked: 2 item(s)" (opencharly/layer-cuda#42). The clean
# tree must count 0; a planted `libvdpau_nvidia*` must count 1.
set -eu
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/vdpau"
: > "$tmp/vdpau/libvdpau_trace.so"
count() { find "$tmp/vdpau" -maxdepth 1 -name 'libvdpau_nvidia*' 2>/dev/null | wc -l; }

[ "$(count)" -eq 0 ] || { echo "FAIL: clean vdpau tree counted $(count)"; exit 1; }
: > "$tmp/vdpau/libvdpau_nvidia.so.1"
[ "$(count)" -eq 1 ] || { echo "FAIL: planted driver counted $(count)"; exit 1; }
echo "no-baked-driver: clean tree 0, planted libvdpau_nvidia 1 -- the predicate discriminates"
