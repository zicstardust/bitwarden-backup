FROM debian:12.9 AS builder

WORKDIR /src

COPY src/download_powershell.sh .

RUN apt update -y; \
    apt install wget -y; \
    chmod +x ./download_powershell.sh; \
    ./download_powershell.sh

FROM debian:12.9-slim

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2025.1.1"

ENV NODE_OPTIONS="--no-deprecation"

ENV UID=1000
ENV GID=1000
ENV INTERVAL='1d'
ENV KEEP_LAST=0
ENV BACKUP_ORGANIZATION_ONLY=False

WORKDIR /app

COPY --from=builder /src/powershell.tar.gz .
COPY src/start.ps1 .

RUN apt update; \
    apt -y install --no-install-recommends --no-install-suggests \
                libc6 \
                libgcc-s1 \
                libgssapi-krb5-2 \
                libicu72 \
                libssl3 \
                libstdc++6 \
                zlib1g \
                nodejs \
                npm; \
    mkdir -p /opt/microsoft/powershell/7; \
    tar zxf /app/powershell.tar.gz -C /opt/microsoft/powershell/7; \
    chmod +x /opt/microsoft/powershell/7/pwsh; \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh; \
    rm -f /app/powershell.tar.gz; \
    npm install -g @bitwarden/cli

RUN groupadd -g ${GID} bitwarden; \
    useradd bitwarden -u ${UID} -g bitwarden; \
    mkdir -p /data; \
    chown -R bitwarden:bitwarden /data; \
    mkdir -p "/home/bitwarden/.config/Bitwarden CLI"; \
    touch "/home/bitwarden/.config/Bitwarden CLI/data.json"; \
    chown -R bitwarden:bitwarden /home/bitwarden; \
    chown -R bitwarden:bitwarden /app; \
    chmod +x /app/start.ps1

USER bitwarden

CMD [ "pwsh", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "/app/start.ps1" ]