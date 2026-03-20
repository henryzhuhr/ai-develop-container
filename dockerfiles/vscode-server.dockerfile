ARG VSCODE_SERVER_COMMITS="07ff9d6178ede9a1bd12ad3399074d726ebe6e43,cb1933bbc38d329b3595673a600fab5c7368f0a7,42b266171e51a016313f47d0c48aca9295b9cbb2"
ARG VSCODE_SERVER_CHANNEL="stable"

FROM ubuntu:24.04 AS vscode-server-builder

ARG VSCODE_SERVER_COMMITS
ARG VSCODE_SERVER_CHANNEL
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl tar && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="${TARGETARCH:-}"; \
    if [ -z "${arch}" ]; then \
      case "$(uname -m)" in \
        x86_64) arch="amd64" ;; \
        aarch64|arm64) arch="arm64" ;; \
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;; \
      esac; \
    fi; \
    case "${arch}" in \
      amd64) vscode_arch="x64" ;; \
      arm64) vscode_arch="arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${arch}" >&2; exit 1 ;; \
    esac; \
    old_ifs="$IFS"; \
    IFS=','; \
    for commit in ${VSCODE_SERVER_COMMITS}; do \
      target_dir="/out/${commit}"; \
      extract_dir="/tmp/vscode-server-extract-${commit}"; \
      mkdir -p "${target_dir}" "${extract_dir}"; \
      curl --fail --show-error --silent --location \
        --retry 5 --retry-all-errors --retry-delay 2 \
        --connect-timeout 10 --max-time 300 \
        "https://update.code.visualstudio.com/commit:${commit}/server-linux-${vscode_arch}/${VSCODE_SERVER_CHANNEL}" \
        -o "/tmp/vscode-server-${commit}.tar.gz"; \
      tar -xzf "/tmp/vscode-server-${commit}.tar.gz" -C "${extract_dir}"; \
      entry_count="$(find "${extract_dir}" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')"; \
      if [ "${entry_count}" = "1" ] && [ -d "$(find "${extract_dir}" -mindepth 1 -maxdepth 1)" ]; then \
        top_dir="$(find "${extract_dir}" -mindepth 1 -maxdepth 1)"; \
        cp -a "${top_dir}/." "${target_dir}/"; \
      else \
        cp -a "${extract_dir}/." "${target_dir}/"; \
      fi; \
      touch "${target_dir}/0"; \
      rm -rf "/tmp/vscode-server-${commit}.tar.gz" "${extract_dir}"; \
    done; \
    IFS="$old_ifs"

FROM ubuntu:24.04

ARG VSCODE_SERVER_COMMITS

# COPY --from=vscode-server-builder /out/ /root/.vscode-server/bin/

ENV VSCODE_SERVER_COMMITS=${VSCODE_SERVER_COMMITS}

CMD ["bash", "-lc", "set -euo pipefail; printf '%s\n' ${VSCODE_SERVER_COMMITS//,/ }; ls -1 /root/.vscode-server/bin"]
