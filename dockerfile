#FROM node:lts-alpine
FROM node:24.12-alpine


LABEL VERSION="2025.12.1"

ENV NODE_OPTIONS="--no-deprecation"
ENV BITWARDENCLI_APPDATA_DIR="/app"


WORKDIR /app

COPY src/* .
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache \
      shadow \
      bash \
      tzdata \
      su-exec; \
    mkdir -p /data; \
    touch "/app/data.json"; \
    npm install -g @bitwarden/cli; \
    chmod +x /entrypoint.sh /app/main.sh

VOLUME [ "/data" ]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/app/main.sh"]
