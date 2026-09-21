# md-subject-converter-action

## Getting Started

This action converts the markdown subject to a PDF and HTML version.
Files matching `README*.md` are excluded from conversion, but they are still included in the uploaded workflow artifact.

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
        uses: Epitech/md-subject-converter-action@v1
        with:
          ghcr_token: ${{ secrets.EDEX_PACKAGE_READ }}
```

`permissions: contents: write` is **required**: without it the action cannot create the release that
holds the converted files. Set `publish_release: 'false'` if you only want the workflow artifact.

## Where the converted files land

The action publishes its output twice:

- **As a release.** Every run on the default branch recreates a rolling release tagged `subject`
  (configurable with `release_tag`) and attaches every `.pdf`, `.html` and `.pptx` to it. Because the
  tag is fixed, the download URL is stable:
  `https://github.com/<owner>/<repo>/releases/download/subject/<file>.pdf`.
  The release is recreated from scratch on each run, so a renamed or deleted subject leaves no stale
  asset behind. Nothing is published from a pull request, from a non-default branch, or when the
  conversion failed.
- **As a workflow artifact.** Kept as a fallback — it is also produced on pull requests and when the
  conversion fails, so a partial output can still be retrieved. Unlike the release it preserves the
  directory layout and includes `README*.md`, `img/` and `resources/`.

Release assets are **flat**: two converted files sharing the same base name in different directories
(`en/subject.pdf` and `fr/subject.pdf`) become two assets with the same name, and the second
overwrites the first. Use the workflow artifact for such repositories.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `ghcr_token` | yes | — | Token or password used to log in to `ghcr.io` |
| `ghcr_username` | no | `edex-argos` | GitHub username for the Docker login |
| `md_path` | no | `*.md` | `find -name` **pattern** (not a path) matching the files to convert, at any depth |
| `docker_image` | no | `ghcr.io/epitech/docker-md-converter:master` | Converter image to run |
| `github_token` | no | `${{ github.token }}` | Token used to create the release |
| `release_tag` | no | `subject` | Tag of the rolling release holding the converted files |
| `publish_release` | no | `true` | Publish the converted files as release assets |
| `upload_artifact` | no | `true` | Also upload the converted files as a workflow artifact |

## Requirements

The runner must be **self-hosted** with Docker and GNU `find` available.
