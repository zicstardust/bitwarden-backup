FROM debian:12 AS build

WORKDIR /src

RUN apt update -y; \
    apt upgrade -y; \
    apt install wget unzip -y

COPY src/download.sh .

RUN chmod +x /src/download.sh; \
    /src/download.sh

FROM debian:12-slim

ENV UID=1000
ENV GID=1000
ENV BW_SERVER="vault.bitwarden.com"
ENV INTERVAL='24h'

WORKDIR /app

COPY --from=build /src/bw .
COPY src/start.sh .

RUN groupadd -g ${GID} bitwarden; \
useradd bitwarden -u ${UID} -g bitwarden; \
mkdir -p "/home/bitwarden/.config/Bitwarden CLI"; \
touch "/home/bitwarden/.config/Bitwarden CLI/data.json"; \
chown -R bitwarden:bitwarden /home/bitwarden; \
chown -R bitwarden:bitwarden /app; \
chmod +x /app/start.sh

USER bitwarden

CMD /app/start.sh