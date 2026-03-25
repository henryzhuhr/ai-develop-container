#!/bin/bash

set -euo pipefail

SOURCE_SSH_DIR="/data/.ssh"
SOURCE_GITCONFIG="/data/.gitconfig"

if [ -d "${SOURCE_SSH_DIR}" ]; then
  rm -rf "/root/.ssh"
  mkdir -p "/root/.ssh"
  cp -a "${SOURCE_SSH_DIR}/." "/root/.ssh/"

  chown -R root:root "/root/.ssh"
  find "/root/.ssh" -type d -exec chmod 700 {} +
  find "/root/.ssh" -type f -exec chmod 600 {} +
  find "/root/.ssh" -type f -name '*.pub' -exec chmod 644 {} +
fi

if [ -f "${SOURCE_GITCONFIG}" ]; then
  cp "${SOURCE_GITCONFIG}" "/root/.gitconfig"
  chown root:root "/root/.gitconfig"
  chmod 600 "/root/.gitconfig"
fi
