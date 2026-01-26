#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.2.1"
    exit 1
fi

VERSION=$1

if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-rc\.[0-9]+)?$ ]]; then
    echo "Error: Version must be in format vX.Y.Z or vX.Y.Z-rc.N (e.g., v1.2.1 or v1.2.1-rc.1)"
    exit 1
fi

COMMIT=$(git rev-parse HEAD)

IS_RC=false
if [[ $VERSION =~ -rc\.[0-9]+$ ]]; then
    IS_RC=true
fi

if [ "$IS_RC" = true ]; then
    echo "Release candidate detected, creating only patch tag:"
    echo "  - $VERSION"
    git tag -f "$VERSION" "$COMMIT"
else
    IFS='.' read -ra PARTS <<< "${VERSION#v}"
    MAJOR="v${PARTS[0]}"
    MINOR="v${PARTS[0]}.${PARTS[1]}"
    PATCH="$VERSION"

    echo "Creating/updating tags:"
    echo "  - $MAJOR"
    echo "  - $MINOR"
    echo "  - $PATCH"

    git tag -f "$MAJOR" "$COMMIT"
    git tag -f "$MINOR" "$COMMIT"
    git tag -f "$PATCH" "$COMMIT"
fi

echo ""
echo "Tags created/updated successfully!"
echo "To push tags, run: git push --tags --force"
