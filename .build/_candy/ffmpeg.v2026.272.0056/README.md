# ffmpeg

FFmpeg — command-line audio/video transcoding and media inspection.

The `ffmpeg` candy installs the `ffmpeg` package (from the negativo17
`fedora-multimedia` repo on Fedora, `core`/`extra` on Arch). It ships the
`ffmpeg` transcoder and the `ffprobe` media inspector under `/usr/bin`, both of
which print a version banner to stdout — so their presence and basic operability
are directly verifiable.

This is the negativo17 **nonfree** build (H.264/AAC support), not the RPM Fusion
`ffmpeg-free`. All candies that need `ffmpeg` declare it as a dependency rather
than independently adding the negativo17 repo, so there is a single authoritative
install point.

## What it provides

| Property | Value |
|---|---|
| Layer / candy | `ffmpeg` |
| Binaries | `/usr/bin/ffmpeg`, `/usr/bin/ffprobe` |
| Distro | `arch`, `fedora` |
| Repo | negativo17 `fedora-multimedia` (Fedora) |
| Service / port | none |

## How to use it

Compose the layer as an inline list in a box body:

```yaml
my-box:
  candy:
    base: fedora
    candy:
      - '@github.com/opencharly/layer-ffmpeg:v2026.239.1614'
```

Then, inside the built image:

```bash
ffmpeg -version     # ffmpeg version x.y
ffprobe -version    # ffprobe version x.y
```

## Layout

- `charly.yml` — the `ffmpeg:` candy entity (the per-distro package arm, the
  Fedora `fedora-multimedia` repo, the `check:` assertions) and the embedded
  `ffmpeg-skill:` skill entity.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — this user overview.

## Related

- Owning skill: `/charly-selkies:ffmpeg`
- Depends on it: `/charly-distros:cuda`, `/charly-tools:whisper`,
  `/charly-hermes:hermes`, `/charly-immich:immich`
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI and image builder
- [`opencharly/opencharly`](https://github.com/opencharly/opencharly) — the umbrella
