FROM node:lts-alpine

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2025.7.0"

ENV NODE_OPTIONS="--no-deprecation"
ENV BITWARDENCLI_APPDATA_DIR="/app"

ENV UID=1000
ENV GID=1000
ENV INTERVAL='1d'
ENV KEEP_LAST=0
ENV BACKUP_ORGANIZATION_ONLY=False
ENV BACKUP_FORMAT='encrypted_json'

WORKDIR /app

COPY app.js package.json package-lock.json ./
COPY entrypoint.sh /entrypoint.sh

RUN apk add --no-cache \
      shadow \
      su-exec; \
    mkdir -p /data; \
    touch "/app/data.json"; \
    npm install; \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
