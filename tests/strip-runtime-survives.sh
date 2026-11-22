#!/usr/bin/env bash
# tests/strip-runtime-survives.sh — the executable control for
# `cuda-drop-driver-userspace` (opencharly/layer-cuda#34).
#
# The step proves what it DELETES and, since layer-cuda#23, what it must KEEP.
# Reading the predicate cannot prove either: the over-broad form (`libcuda*`)
# looked right in review and deleted the CUDA runtime the layer had just
# stitched. This fixture EXECUTES the step's own body — the step is overridable
# for exactly this purpose (CUDA_STRIP_LIB_DIRS / CUDA_STRIP_BIN_DIRS) — against
# a synthetic layout, so the judgement runs without a GPU and without an image.
#
#   anchored  the shipped predicate removes the driver and KEEPS the runtime
#   mutation  the prefix glob (layer-cuda#23's regression) MUST fail
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
candy="$here/charly.yml"
[ -f "$candy" ] || { echo "FAIL: $candy not found" >&2; exit 1; }

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
body="$work/step.sh"
# Only the shell body: after the step's `command: |`, before the next plan entry,
# with the 16-space YAML indent removed.
awk '
  /id: cuda-drop-driver-userspace/ { on=1 }
  on && /command: \|/ { body=1; next }
  body && /^            - / { exit }
  body { sub(/^                /, ""); print }
' "$candy" > "$body"
grep -q 'libcuda\.so\*' "$body" || { echo "FAIL: the step body was not extracted" >&2; exit 1; }

seed() {  # seed <root>
    local d=$1/lib
    mkdir -p "$d/nvidia" "$d/vdpau" "$d/xorg/modules/drivers" "$1/bin"
    for f in libcuda.so.1 libcudadebugger.so.1 libnvidia-ml.so.1 libnvcuvid.so.1 \
             libcudart.so.13 libcudart_static.a libcublas.so.13; do : > "$d/$f"; done
    : > "$d/nvidia/keep"; : > "$d/xorg/modules/drivers/nvidia_drv.so"
}

fail=0

# --- arm 1: the shipped predicate ------------------------------------------
root="$work/anchored"; seed "$root"
if out=$(env CUDA_STRIP_LIB_DIRS="$root/lib" CUDA_STRIP_BIN_DIRS="$root/bin" bash "$body" 2>&1); then rc=0; else rc=$?; fi
printf 'anchored arm (rc=%s):\n%s\n' "$rc" "$out" | sed 's/^/  /'
[ "$rc" -eq 0 ] || { echo "FAIL: the shipped predicate failed its own survival assertion" >&2; fail=1; }
for keep in libcudart.so.13 libcudart_static.a libcublas.so.13; do
    [ -f "$root/lib/$keep" ] || { echo "FAIL: the anchored strip DELETED $keep" >&2; fail=1; }
done
for gone in libcuda.so.1 libcudadebugger.so.1 libnvidia-ml.so.1 libnvcuvid.so.1; do
    [ -e "$root/lib/$gone" ] && { echo "FAIL: the anchored strip KEPT $gone" >&2; fail=1; }
done
[ -e "$root/lib/nvidia" ] && { echo "FAIL: the nvidia tree survived" >&2; fail=1; }
[ -e "$root/lib/xorg/modules/drivers/nvidia_drv.so" ] && { echo "FAIL: the xorg driver survived" >&2; fail=1; }

# --- arm 2: the prefix-glob mutation MUST fail -----------------------------
root="$work/mutation"; seed "$root"
mut="$work/step-prefix.sh"; sed 's/-name libcuda\.so\*/-name libcuda*/' "$body" > "$mut"
if out=$(env CUDA_STRIP_LIB_DIRS="$root/lib" CUDA_STRIP_BIN_DIRS="$root/bin" bash "$mut" 2>&1); then rc=0; else rc=$?; fi
printf 'mutation arm (rc=%s):\n%s\n' "$rc" "$out" | sed 's/^/  /'
if [ "$rc" -eq 0 ]; then
    echo "FAIL: the prefix-glob mutation PASSED — the survival assertion is not discriminating" >&2; fail=1
fi
case "$out" in
  *libcudart*) ;;
  *) echo "FAIL: the mutation failed without naming a runtime file it deleted" >&2; fail=1 ;;
esac

if [ "$fail" -eq 0 ]; then
    echo 'strip-runtime-survives: both arms behaved (anchored kept the runtime; the prefix glob failed naming libcudart)'
else
    echo 'strip-runtime-survives: FAILED'
fi
exit "$fail"
