FROM debian:12.10-slim

LABEL NAME="Bitwarden CLI"
LABEL VERSION="2025.3.0"

ENV NODE_OPTIONS="--no-deprecation"

ENV UID=1000
ENV GID=1000
ENV INTERVAL='1d'
ENV KEEP_LAST=0
ENV BACKUP_ORGANIZATION_ONLY=False

WORKDIR /app

COPY src/install_powershell.sh .
COPY src/start.ps1 .

RUN apt update; \
    #apt install wget -y; \
    apt install --no-install-recommends --no-install-suggests wget ca-certificates -y; \
    chmod +x ./install_powershell.sh; \
    ./install_powershell.sh; \
    rm -f /app/install_powershell.sh; \
    #apt remove wget -y; \
    apt remove wget ca-certificates -y; \
    apt autoremove -y

RUN apt -y install --no-install-recommends --no-install-suggests \
        libc6 \
        libgcc-s1 \
        libgssapi-krb5-2 \
        libicu72 \
        libssl3 \
        libstdc++6 \
        zlib1g \
        nodejs \
        npm; \
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