FROM node:lts-alpine

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2025.6.1"

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

RUN apk add --no-cache --virtual builddeps shadow; \
    groupmod --gid ${GID} node; \
    usermod --uid ${UID} node; \
    apk del builddeps; \
    mkdir -p /data; \
    touch "/app/data.json"; \
    chown -R node:node /data /app; \
    npm install;

USER node

#WORKDIR /data

CMD [ "npm", "start" ]