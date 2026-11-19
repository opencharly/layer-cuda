---
name: cuda
description: 'CUDA toolkit, cuDNN, ONNX Runtime, and NVIDIA GPU development libraries
  from negativo17 repos.

  Depends on the nvidia candy for runtime support. Use when working with GPU computing,
  CUDA,

  cuDNN, machine learning infrastructure, or NVIDIA development tools.'
---

# cuda -- CUDA development toolkit

CUDA compiler, cuDNN, ONNX Runtime, and GPU development libraries. Depends on the `nvidia` candy for its
package arms and its ordering, not for what survives: this layer's own strip removes the driver user-space
`nvidia-utils` drags in (including `nvidia-ctk`'s siblings), so a cuda-composing image carries neither a
driver library nor an `nvidia*` binary.

## Candy Properties

| Property | Value |
|----------|-------|
| Install files | `task:`, `charly.yml` |
| Depends | `nvidia`, `ffmpeg` |

## Environment Variables

| Variable | Value |
|----------|-------|
| `CUDA_HOME` | `/usr` |

## Packages

RPM: `cuda-nvcc`, `cuda-cudart-devel`, `cuda-cudart-static`, `cuda-nvrtc-devel`, `cuda-cupti-devel`, `cccl-devel`, `cuda-cudnn`, `libcurand-devel`, `libcufile-devel`, `onnxruntime`, `libaio-devel`, `cpio`

PAC: `cuda`, `cudnn`, `python-onnxruntime-cpu`

**Note:** FFmpeg codec libraries are provided via the `ffmpeg` dependency candy rather than installed directly. On Fedora, CUDA packages come from the negativo17 `fedora-nvidia` repo (added by the `nvidia` candy); on Arch/CachyOS they come from the standard repos.

## Multi-distro (Fedora + Arch)

The candy is multi-distro. The `distro.arch` section installs `cuda`, `cudnn`,
and `python-onnxruntime-cpu` from the Arch repos. Arch installs CUDA under
`/opt/cuda` — its toolkit headers under `/opt/cuda/targets/x86_64-linux/include/` —
while `CUDA_HOME` is `/usr`, so the Arch path links **every entry of those trees into
`/usr`** — files of any extension and subtrees alike, enumerated rather than
pattern-matched. `nvcc` computes its include root *relative to its own executable*, and
`/usr/bin/nvcc` is a symlink, so anything not reachable under `/usr/include` cannot be
found: `cuda_runtime.h`'s own `#include` fails and every CUDA build dies at CMake's
`enable_language(CUDA)` with "No such file or directory". Matching on patterns produced
both of those failures, on both Arch arms, while every probe in this plan still passed
(opencharly/layer-cuda#9): first a `*.h` glob that linked the top-level headers but not
the `crt/` and `cccl/` subtrees, then the same glob missing the `.hpp` half of the
`_functions` family once the subtrees were linked. The check `cuda-arch-header-root`
preprocesses a real CUDA translation unit to prove the whole header root resolves.

With that stitch in place, the same `nvcc`, header, and library paths resolve
identically on Fedora and on Arch/CachyOS.

## Driver user-space vs the CUDA runtime — the strip and what it must keep

Installing the toolkit also drags in host-coupled driver user-space (`pacman -S cuda` depends on
`nvidia-utils`; `dnf install cuda-nvcc` pulls `nvidia-driver` user-space on some distros), which shadows the
driver the container runtime injects. `cuda-drop-driver-userspace` removes it, and it is the ONE copy of
that removal: `layer-cdi` deliberately keeps none of its own and only asserts the result.

Three library families share `/usr/lib64` in the resulting image, and only the first may be deleted:

| family | names | disposition |
|---|---|---|
| **driver** | `libcuda.so{,.1,.<ver>}`, `libcudadebugger.so{,.1,.<ver>}`, `libnvidia-*.so*`, `libnvcuvid*`, `libnvoptix*`, `libGLX_nvidia*`, `libEGL_nvidia*`, `libGLESv1_CM_nvidia*`, `libGLESv2_nvidia*` | **deleted** |
| **runtime** | `libcudart.so{,.13,.13.5.37}`, `libcudart_static.a`, `libcudadevrt.a` | kept — this layer installs them |
| **compute** | `libcublas*`, `libcudnn*`, `libnvrtc*`, `libcurand*`, `libcufft*`, `libcusparse*`, `libcusolver*`, `libnvJitLink*` | kept — this layer installs them |

The predicate is anchored, not a prefix: `libcuda.so*`, never `libcuda*`. The prefix family `libcuda*` also
contains `libcudart*` and `libcudadevrt*`, so a prefix glob deletes the very runtime the stitch just put in
place and the `ls /usr/lib64/libcudart.so*` check then exits 2 (opencharly/layer-cuda#23).
`libcudadebugger.so*` is listed explicitly because it *is* driver user-space — it is in the CDI spec's
injected set — but does not carry the `libcuda.so` stem.

The step also asserts what it KEEPS: every runtime/compute library present before the strip must still be
present after it, and the build fails naming the file otherwise. The residue count alone cannot tell the two
families apart, which is exactly how the runtime came to be deleted while the build stayed green. Both
directory lists are overridable (`CUDA_STRIP_LIB_DIRS`, `CUDA_STRIP_BIN_DIRS`) so the step can be executed
against a fixture without a GPU or an image build.

## Install tasks

Extracts cuDNN headers from `cuda-cudnn-devel` RPM (bypasses driver dependency via rpm2cpio) on Fedora; the `/opt/cuda → /usr` symlink stitch runs on Arch/CachyOS.

## Usage

```yaml
# charly.yml
nvidia:
  base: fedora-nonfree
  candy:
    - nvidia
    - cuda
```

## Used In Boxes

- `/charly-distros:nvidia` (base for all GPU boxes)
- `/charly-immich:immich-ml`

## Related Candies

- `/charly-distros:nvidia` — NVIDIA GPU runtime (driver libs, CDI toolkit) — required dependency
- `/charly-selkies:ffmpeg` — FFmpeg multimedia (nonfree codecs) — required dependency
- `/charly-distros:rocm` — AMD GPU counterpart (ROCm runtime + OpenCL)
- `/charly-languages:python-ml` — ML Python environment (depends on cuda)
- `/charly-jupyter:jupyter` — Jupyter notebooks (depends on cuda)
- `/charly-ollama:ollama` — LLM server (depends on cuda)
- `/charly-comfyui:comfyui` — image generation (depends on cuda)

## Related

- `/charly-image:layer` — candy authoring reference (`charly.yml` schema, task verbs, service declarations)
- `/charly-check:check` — declarative testing (`check:` block, `charly check box`, `charly check live`)
