# cuda

CUDA toolkit layer for OpenCharly GPU images — Arch/CachyOS.

The `cuda` candy installs the CUDA compiler driver (`nvcc`), the CUDA runtime/dev
libraries (`cudart`, `nvrtc`, `cupti`, `curand`, `cccl`, `cufile`), cuDNN, and
onnxruntime, stitched into the canonical `/usr` layout on Arch/CachyOS.
It depends on the `ffmpeg` candy for codec libraries.

The packages install under `/opt/cuda`, so post-install tasks symlink
the binaries, headers, and libraries
into the same `/usr`-rooted paths. With that stitch in place, every downstream
GPU consumer compiles against one layout regardless of distro. Each artifact is a
real file or library on disk, so its presence is directly verifiable.

## What it provides

| Property | Value |
|---|---|
| Layer / candy | `cuda` |
| Requires | `layer-nvidia`, `layer-ffmpeg` |
| Environment | `CUDA_HOME=/usr` |
| Binaries | `/usr/bin/nvcc` (+ `cuobjdump`, `ptxas`, ...) |
| Headers | `/usr/include/cudnn.h`, CUDA headers |
| Libraries | `/usr/lib64/libcudart.so*`, `libcudnn`, `libcurand`, ... |
| Service / port | none |

Per-distro packages:

- `arch` — `cuda`, `cudnn`, `python-onnxruntime-cpu`.

## How to use it

Compose the layer by pinning this repo in a box's `candy:` list:

```yaml
my-gpu-builder:
  candy:
    base: cachyos.cachyos
    candy:
      - '@github.com/opencharly/layer-cuda:v2026.326.2259'
```

A pod does not compose this layer directly: it takes the driver from the host through CDI and
composes the toolkit only when its class needs it (`podcdi.pod-cdi` owns that today, see
`/charly-distros:cdi`). A VM composes `layer-nvidia` beside it. After the
image is built (no physical GPU needed to verify the artifacts):

```bash
nvcc --version
ls /usr/include/cudnn.h
ls /usr/lib64/libcudart.so*
```

## Layout

- `charly.yml` — the `cuda:` candy entity: the `require:` deps, the per-distro
  package arms and repos, the `CUDA_HOME` env, the stitch + extract `plan:`
  steps, and the `check:` assertions, plus the embedded `skill:` entity.
- `CHANGELOG/` — per-CalVer release notes.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — this user overview.

## Related

- Owning skill: `/charly-distros:cuda` — the CUDA toolkit, cuDNN, and ONNX
  Runtime reference
- GPU runtime: `/charly-distros:nvidia`
- Codecs: `/charly-selkies:ffmpeg`
- Derived GPU boxes: `/charly-languages:python-ml`, `/charly-ollama:ollama`,
  `/charly-comfyui:comfyui`, `/charly-immich:immich`
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI and image builder
- [`opencharly/opencharly`](https://github.com/opencharly/opencharly) — the umbrella
