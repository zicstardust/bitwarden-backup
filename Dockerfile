FROM alpine:3.24.1

ARG TARGETARCH

ARG NODE_VERSION="24.21.0"
ARG BW_CLI_VERSION="2026.8.0"
ARG DOWNLOAD_BASE_URL="https://unofficial-builds.nodejs.org/download/release"


ENV NODE_OPTIONS="--no-deprecation"
ENV BITWARDENCLI_APPDATA_DIR="/config"


WORKDIR /data

COPY src/* /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN chmod -R +x /entrypoint.sh /usr/local/bin/*; \
    apk update; \
    apk upgrade -a; \
    apk add --no-cache \
      shadow \
      bash \
      tzdata \
      su-exec \
      libstdc++ \
      libgcc; \
    \
    adduser -D -u 1000 -s /bin/nologin -h /home/bwbackup bwbackup; \
    \
    apk add --no-cache --virtual .temp-deps curl; \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        NODE_ARCH="arm64"; \
    elif [ "${TARGETARCH}" = "amd64" ]; then \
        NODE_ARCH="x64"; \
    else \
        echo "Unsupported architecture: ${TARGETARCH}"; \
        exit 1; \
    fi; \
    curl -o node.tar.gz ${DOWNLOAD_BASE_URL}/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}-musl.tar.gz; \
    unset NODE_ARCH; \
    tar -xzf node.tar.gz -C /usr/local --strip-components=1; \
    rm -f node.tar.gz; \
    apk del .temp-deps; \
    \
    npm install -g @bitwarden/cli@${BW_CLI_VERSION};
    

VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["main.sh"]
