FROM alpine:3.21.1

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2024.12.0"

ENV NODE_OPTIONS="$NODE_OPTIONS --no-deprecation"

ENV UID=1000
ENV GID=1000
ENV BW_SERVER="vault.bitwarden.com"
ENV INTERVAL='24h'

WORKDIR /app

COPY src/start.sh .

RUN apk update; \
    apk add npm bash; \
    npm install -g @bitwarden/cli; \
    addgroup bitwarden -g ${GID}; \
    adduser bitwarden -u ${UID} -D -G bitwarden; \
    mkdir -p /data; \
    chown -R bitwarden:bitwarden /data; \
    mkdir -p "/home/bitwarden/.config/Bitwarden CLI"; \
    touch "/home/bitwarden/.config/Bitwarden CLI/data.json"; \
    chown -R bitwarden:bitwarden /home/bitwarden; \
    chown -R bitwarden:bitwarden /app; \
    chmod +x /app/start.sh

USER bitwarden

CMD [ "/app/start.sh" ]