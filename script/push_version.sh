#!/bin/bash
set -e

# Usage:
#   ./script/push_version.sh 6.1.0                # Publishes all 3 packages via publish_6.1.0
#   ./script/push_version.sh core 1.0.0           # Publishes vexana_core via vexana_core-v1.0.0
#   ./script/push_version.sh vexana 6.1.0         # Publishes vexana via vexana-v6.1.0
#   ./script/push_version.sh jaspr 0.1.0          # Publishes vexana_jaspr via vexana_jaspr-v0.1.0

if [ "$#" -eq 1 ]; then
  TAG="publish_$1"
elif [ "$#" -eq 2 ]; then
  case "$1" in
    core|vexana_core)
      TAG="vexana_core-v$2"
      ;;
    vexana)
      TAG="vexana-v$2"
      ;;
    jaspr|vexana_jaspr)
      TAG="vexana_jaspr-v$2"
      ;;
    *)
      echo "Unknown package: $1 (expected: core, vexana, jaspr)"
      exit 1
      ;;
  esac
else
  echo "Usage: $0 [<package>] <version>"
  exit 1
fi

echo "Creating and pushing tag: $TAG"
git tag "$TAG"
git push origin "$TAG"
