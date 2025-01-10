FROM alpine:3.21.1

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2024.12.0"

ENV NODE_OPTIONS="--no-deprecation"
ENV POWERSHELL_VERSION="7.4.6"

ENV UID=1000
ENV GID=1000
ENV INTERVAL='1d'
ENV KEEP_LAST=0
ENV BACKUP_ORGANIZATION_ONLY=False

WORKDIR /app

COPY src/start.ps1 .

RUN apk --no-cache update; \
    apk add --no-cache npm \
                        ca-certificates \
                        less \
                        ncurses-terminfo-base \
                        krb5-libs \
                        libgcc \
                        libintl \
                        libssl3 \
                        libstdc++ \
                        tzdata \
                        userspace-rcu \
                        zlib \
                        icu-libs \
                        curl; \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
                                                                lttng-ust \
                                                                 openssh-client; \
    curl -L https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz; \
    mkdir -p /opt/microsoft/powershell/7; \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7; \
    rm -f /tmp/powershell.tar.gz; \
    chmod +x /opt/microsoft/powershell/7/pwsh; \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh; \
    npm install -g @bitwarden/cli; \
    addgroup bitwarden -g ${GID}; \
    adduser bitwarden -u ${UID} -D -G bitwarden; \
    mkdir -p /data; \
    chown -R bitwarden:bitwarden /data; \
    mkdir -p "/home/bitwarden/.config/Bitwarden CLI"; \
    touch "/home/bitwarden/.config/Bitwarden CLI/data.json"; \
    chown -R bitwarden:bitwarden /home/bitwarden; \
    chown -R bitwarden:bitwarden /app; \
    chmod +x /app/start.ps1

USER bitwarden

CMD [ "pwsh", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "/app/start.ps1" ]