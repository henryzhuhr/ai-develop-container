#!/bin/bash

set -euo pipefail

IMAGE_NAME=${1:-"ai-develop-container:0.0.1-dev"}
VSCODE_SERVER_COMMIT=${VSCODE_SERVER_COMMIT:-"07ff9d6178ede9a1bd12ad3399074d726ebe6e43"}

echo "Verifying image: ${IMAGE_NAME}"

docker run --rm "${IMAGE_NAME}" bash -lc "
  set -euo pipefail
  node -v
  go version
  python3 --version
  uv --version
  java -version
  javac -version
  codex --version
  if command -v claude >/dev/null 2>&1; then
    claude --version
  elif command -v claude-code >/dev/null 2>&1; then
    claude-code --version
  else
    echo 'claude command not found' >&2
    exit 1
  fi
  test -d /root/.vscode-server/bin/${VSCODE_SERVER_COMMIT}
  test -f /root/.vscode-server/bin/${VSCODE_SERVER_COMMIT}/0
  test -x /root/.vscode-server/bin/${VSCODE_SERVER_COMMIT}/bin/code-server
  echo \"VS Code Server commit ${VSCODE_SERVER_COMMIT} is preinstalled.\"
"
