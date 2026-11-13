#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

swiftc \
  "$ROOT_DIR/DarkMaze/GameScene/MazeLib.swift" \
  "$ROOT_DIR/Tests/MazeValidation/AppStateStub.swift" \
  "$ROOT_DIR/Tests/MazeValidation/main.swift" \
  -o "$BUILD_DIR/maze-validation"

"$BUILD_DIR/maze-validation"
