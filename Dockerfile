FROM node:lts-alpine

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2025.3.0"

ENV NODE_OPTIONS="--no-deprecation"
ENV BITWARDENCLI_APPDATA_DIR="/app"

ENV UID=1000
ENV GID=1000
ENV INTERVAL='1d'
ENV KEEP_LAST=0
ENV BACKUP_ORGANIZATION_ONLY=False

WORKDIR /app
COPY app.js .
COPY package*.json .

#RUN npm install -g @bitwarden/cli; \
RUN groupmod -g {GID} node; \
    usermod -u ${UID} node; \
    mkdir -p /data /app; \
    touch "/app/data.json"; \
    chown -R node:node /data /app; \
    npm install;

USER node

WORKDIR /data

CMD [ "node", "/app/app.js" ]