# AGENTS.md — layer-cuda

Standalone candy repo for the `cuda` layer — the CUDA toolkit, cuDNN, and ONNX
Runtime stitched into the canonical `/usr` layout on Fedora and Arch. The candy
lives in `charly.yml` at the repo root: the `require:` deps (`nvidia`, `ffmpeg`),
the per-distro package arms and repos, the `CUDA_HOME` environment, the stitch +
extract `plan:` steps, the `check:` assertions, and the embedded `skill:` entity
projected into the marketplace corpus as `/charly-distros:cuda`.

Canonical files:

- `charly.yml` — the `cuda:` candy entity and the `cuda-skill:` skill entity.
- `CHANGELOG/` — per-CalVer release history; read it before changing baked
  checks.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-distros:cuda` — the owning skill. The toolkit layout, the per-distro
  stitch, and verification. Load before editing or troubleshooting the layer.
- `/charly-image:layer` — the candy authoring reference (`charly.yml` schema,
  `plan:` step verbs incl. `check:`, per-distro `distro:` arms, package/repo
  sections, and service declarations). Load before editing any entity field or
  plan step.

## Build / validate / test

- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo has **no
  per-repo candy gate** and ships only `.github/workflows/tag-on-merge.yml`.
- The candy's `plan:` `check:` steps are the functional evidence; they must stay
  valid on every distro arm they run on. Scope a distro-specific check in the
  command itself — the check runner does not honour runner-level
  `exclude-distro` fields.

## Modify this repo

- Edit the `cuda:` candy entity AND the `cuda-skill:` skill entity in
  `charly.yml` together. The skill is the projected usage source, so a package,
  distro-arm, or behaviour change not mirrored in the skill leaves the corpus
  stale.
- Package changes go in the top-level `package:` or a `distro:` arm; repository
  and signing policy go in the matching `distro:` arm's `repo:` block. NVIDIA
  rotates its repo signing key — the `cuda-fedora43-x86_64` `gpgkey` must name
  the key the live `.repo` file declares.
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
