#!/bin/bash
set -e

# Usage:
#   ./script/push_version.sh core      # tags vexana_core-v<version>
#   ./script/push_version.sh vexana    # tags vexana-v<version>
#   ./script/push_version.sh jaspr     # tags vexana_jaspr-v<version>
#
# The version is read from the package's pubspec.yaml, so the tag always
# matches what pub.dev expects. Publish core first when the others need it.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$1" in
  core | vexana_core) PACKAGE="vexana_core" ;;
  vexana) PACKAGE="vexana" ;;
  jaspr | vexana_jaspr) PACKAGE="vexana_jaspr" ;;
  *)
    echo "Usage: $0 <core|vexana|jaspr>"
    exit 1
    ;;
esac

VERSION="$(sed -n 's/^version: *//p' "$REPO_ROOT/packages/$PACKAGE/pubspec.yaml")"
if [ -z "$VERSION" ]; then
  echo "Could not read version from packages/$PACKAGE/pubspec.yaml"
  exit 1
fi

TAG="$PACKAGE-v$VERSION"
echo "Creating and pushing tag: $TAG"
git tag "$TAG"
git push origin "$TAG"
