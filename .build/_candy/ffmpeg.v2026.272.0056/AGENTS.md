# AGENTS.md — layer-ffmpeg

Standalone candy repo for the `ffmpeg` layer — the negativo17 nonfree FFmpeg
build (H.264/AAC) with `ffmpeg` and `ffprobe`. The candy lives in `charly.yml` at
the repo root: the per-distro package arm, the Fedora `fedora-multimedia` repo,
the `check:` assertions, and the embedded `skill:` entity projected into the
marketplace corpus as `/charly-selkies:ffmpeg`.

Canonical files:

- `charly.yml` — the `ffmpeg:` candy entity and the `ffmpeg-skill:` skill entity.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-selkies:ffmpeg` — the owning skill. The negativo17 repo, the nonfree
  codec set, and the downstream consumers. Load before editing or troubleshooting
  the layer.
- `/charly-image:layer` — the candy authoring reference (`charly.yml` schema,
  `plan:` step verbs incl. `check:`, per-distro `distro:` arms, package/repo
  blocks). Load before editing any entity field or plan step.

## Build / validate / test

- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo has **no
  per-repo candy gate** and ships only `.github/workflows/tag-on-merge.yml`.
- The candy's `plan:` `check:` steps are the functional evidence: the
  `/usr/bin/ffmpeg` and `/usr/bin/ffprobe` binaries plus their version banners
  (`ffmpeg version` / `ffprobe version`), and the package-installed check. They
  must stay valid on the `arch`/`fedora` arms they run on.
- This is the nonfree negativo17 build, deliberately distinct from RPM Fusion's
  `ffmpeg-free`; the `fedora-multimedia` repo + `gpgkey` must stay correct.

## Modify this repo

- Edit the `ffmpeg:` candy entity AND the `ffmpeg-skill:` skill entity in
  `charly.yml` together. The skill is the projected usage source, so a package,
  repo, or behaviour change not mirrored in the skill leaves the corpus stale.
- Keep `ffmpeg` as the single authoritative install point: downstream candies
  declare `require: ffmpeg` rather than adding the negativo17 repo themselves.
- New behaviour claims belong in the `plan:` as an observable `check:` step, and
  in the skill body.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge
  on PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the
  PR body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly` and `charly/AGENTS.md` in the charly repo. Do not
  restate its rules here.
