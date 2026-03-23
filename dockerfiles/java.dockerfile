# docker build -f dockerfiles/java.dockerfile -t ai-develop-container:java-only-latest .

FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

WORKDIR /root
USER root

# ============================================================
#   Java 环境
# ============================================================
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends openjdk-21-jdk-headless && \
    rm -rf /var/lib/apt/lists/*

CMD ["bash", "-lc", "set -eux && javac -version && java -version"]
