# md-subject-converter-action

## Getting Started

This action converts the markdown subject to a PDF and HTML version.
Files matching `README*.md` are excluded from conversion, but they are still included in the uploaded workflow artifact.
Files matching `*grading_scale.md` are excluded from conversion **and** from everything the action publishes -- the release archive, the release assets and the workflow artifact.

To use this action, you need to create a workflow file in your repository's `.github/workflows` directory. An example workflow file is shown below:

```yaml
name: Generate PDF and HTML from Markdown
on:
  push:
    paths:
      - "**.md"
      - "**.yml"
      - "**.yaml"
  pull_request:
    branches:
      - main
      - master
    paths:
      - "**.md"
      - "**.yml"
      - "**.yaml"
  workflow_dispatch:

jobs:
  convert_via_pandoc:
    runs-on: self-hosted
    permissions:
      contents: write
    steps:
      - name: Convert markdown to PDF and HTML
        uses: Epitech/md-subject-converter-action@v2
        with:
          ghcr_token: ${{ secrets.EDEX_PACKAGE_READ }}
```

`permissions: contents: write` is **required**: without it the action cannot create the release that
holds the converted files. Set `publish_release: 'false'` if you only want the workflow artifact.

## Where the converted files land

The action publishes its output twice:

- **As a release.** Every run on the default branch creates a **new** release tagged
  `subject-<YYYYMMDD-HHMMSS>` (UTC, prefix configurable with `release_tag_prefix`). Releases are never
  deleted, so every published version of the subject stays available. Each release carries:
  - `<repo>.zip` — the full output with its **directory structure preserved**: the root `README.md`,
    every `.pdf`, `.html` and `.pptx` at any depth, plus `img/` and `resources/`;
  - every `.pdf` as an individual asset, for a direct link without unzipping;
  - the repository's root `README.md`, if it has one.

  Because the tag changes on every run, use the `latest` URLs to always get the newest version:
  - `https://github.com/<owner>/<repo>/releases/latest/download/<repo>.zip`
  - `https://github.com/<owner>/<repo>/releases/latest/download/<subject>.pdf`

  Nothing is published from a pull request, from a non-default branch, or when the conversion failed.
- **As a workflow artifact.** Kept as a fallback — it is also produced on pull requests and when the
  conversion fails, so a partial output can still be retrieved.

Release assets are flat, but only the PDFs are published individually, so the directory structure is
preserved in the zip. Should two PDFs in different directories share a base name, *both* are prefixed
with their path (`day01/subject.pdf` becomes `day01-subject.pdf`) so neither is silently overwritten.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `ghcr_token` | yes | — | Token or password used to log in to `ghcr.io` |
| `ghcr_username` | no | `edex-argos` | GitHub username for the Docker login |
| `md_path` | no | `*.md` | `find -name` **pattern** (not a path) matching the files to convert, at any depth |
| `docker_image` | no | `ghcr.io/epitech/docker-md-converter:master` | Converter image to run |
| `github_token` | no | `${{ github.token }}` | Token used to create the release |
| `release_tag_prefix` | no | `subject` | Prefix of the timestamped tag created for each release |
| `publish_release` | no | `true` | Publish the converted files as release assets |
| `upload_artifact` | no | `true` | Also upload the converted files as a workflow artifact |

## Requirements

The runner must be **self-hosted** with Docker and GNU `find` available.