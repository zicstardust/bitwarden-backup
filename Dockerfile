FROM node:26.8.1-alpine

ARG BW_CLI_VERSION="2026.8.0"

ENV NODE_OPTIONS="--no-deprecation"
ENV BITWARDENCLI_APPDATA_DIR="/app"


WORKDIR /app

COPY src/* /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache \
      shadow \
      bash \
      tzdata \
      su-exec; \
    \
    mkdir -p /data; \
    touch "/app/data.json"; \
    npm install -g @bitwarden/cli@${BW_CLI_VERSION}; \
    \
    chmod -R +x /entrypoint.sh /usr/local/bin/*

VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/main.sh"]
