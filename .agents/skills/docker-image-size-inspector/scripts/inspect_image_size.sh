#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  inspect_image_size.sh <image>

Example:
  inspect_image_size.sh ai-develop-container:0.0.1-dev
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 1
fi

IMAGE="$1"

section() {
  printf '\n== %s ==\n' "$1"
}

run_in_container() {
  docker run --rm --entrypoint "$CONTAINER_SHELL" "$IMAGE" -c "$1"
}

detect_shell() {
  local shell_name

  for shell_name in sh bash; do
    if docker run --rm --entrypoint "$shell_name" "$IMAGE" -c 'exit 0' >/dev/null 2>&1; then
      printf '%s\n' "$shell_name"
      return 0
    fi
  done

  return 1
}

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  printf 'Image not found: %s\n' "$IMAGE" >&2
  exit 1
fi

section "Image Summary"
docker image ls --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' "$IMAGE"
docker image inspect --format 'ID: {{.Id}}
OS/Arch: {{.Os}}/{{.Architecture}}
WorkingDir: {{json .Config.WorkingDir}}
Entrypoint: {{json .Config.Entrypoint}}
Cmd: {{json .Config.Cmd}}' "$IMAGE"

section "Layer History"
docker history --no-trunc "$IMAGE"

if CONTAINER_SHELL="$(detect_shell)"; then
  section "Container Shell"
  printf 'Using shell: %s\n' "$CONTAINER_SHELL"

  section "Top-Level Directories"
  run_in_container 'du -sh /* 2>/dev/null | sort -hr | head -20'

  section "Common Large Directories"
  run_in_container '
for path in /usr /usr/local /opt /root /var /workspace /app /tmp; do
  if [ -e "$path" ]; then
    du -sh "$path" 2>/dev/null
  fi
done | sort -hr
'

  section "/usr/local Breakdown"
  run_in_container '
if [ -d /usr/local ]; then
  du -sh /usr/local/* 2>/dev/null | sort -hr | head -20
fi
'

  section "Global Node Packages"
  run_in_container '
if [ -d /usr/local/lib/node_modules ]; then
  du -sh /usr/local/lib/node_modules/* 2>/dev/null | sort -hr
else
  echo "No global node_modules directory found."
fi
'

  section "Common Cache Directories"
  run_in_container '
found=0
for path in \
  /var/lib/apt/lists \
  /var/cache/apt \
  /root/.npm \
  /root/.cache \
  /root/.cargo \
  /root/go \
  /go/pkg \
  /usr/local/go/pkg; do
  if [ -e "$path" ]; then
    du -sh "$path" 2>/dev/null
    found=1
  fi
done
if [ "$found" -eq 0 ]; then
  echo "No common cache directories found."
fi
'
else
  section "Container Shell"
  echo "No sh/bash shell available inside the image. Skipping in-container du checks."
  echo "Continue with docker history and inspect Dockerfile COPY/RUN steps manually."
fi
