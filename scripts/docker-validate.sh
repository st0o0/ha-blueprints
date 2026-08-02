#!/usr/bin/env bash
# Run the blueprint validator in Docker — no Python on the host required.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME="ha-blueprint-validator"

docker build -q -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile.validate" "$SCRIPT_DIR"

docker run --rm -v "$REPO_ROOT:/blueprints:ro" "$IMAGE_NAME" "$@"
