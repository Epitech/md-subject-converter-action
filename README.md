# md-subject-converter-action

## Getting Started

This action converts the markdown subject to a PDF and HTML version.

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
    runs-on: ubuntu-latest
    steps:
      - name: Convert markdown to PDF and HTML
        uses: Epitech/md-subject-converter-action@v1
        with:
          ghcr_token: ${{ secrets.EDEX_PACKAGE_READ }} 
```