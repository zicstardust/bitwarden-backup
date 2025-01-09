# Automatic Docker Bitwarden Backup

[GitHub](https://github.com/zicstardust/bitwarden-backup)

[Docker Hub](https://hub.docker.com/r/zicstardust/bitwarden-backup)

## Supported Architectures

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | latest, node, native |
| arm64 | ✅ | latest, node |


## Tags


| Tag | Available | Description |
| :----: | :----: |--- |
| [`latest`, `node`](https://github.com/zicstardust/bitwarden-backup/blob/main/Dockerfile) | ✅ | Bitwarden CLI Node version |
| [`native`](https://github.com/zicstardust/bitwarden-backup/blob/main/Dockerfile.native) | ✅ | Bitwarden CLI binary native |

## Usage
### docker-compose
```
services:
  bitwarden-backup:
    restart: unless-stopped 
    container_name: bitwarden-backup
    image: zicstardust/bitwarden-backup:latest
    environment:
      TZ: America/New_York
      UID: 1000
      GID: 1000
      INTERVAL: 1d
      BW_SERVER: ${BW_SERVER}
      BW_CLIENTID: ${BW_CLIENTID}
      BW_CLIENTSECRET: ${BW_CLIENTSECRET}
      MASTER_PASSWORD: ${MASTER_PASSWORD}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
    volumes:
      - /path/to/data/:/data/
```
### docker cli
```
docker run -d \
  --name=bitwarden-backup \
  -e TZ=America/New_York \
  -e UID=1000 \
  -e GID=1000 \
  -e INTERVAL=1d \
  -e BW_SERVER=${BW_SERVER} \
  -e BW_CLIENTID=${BW_CLIENTSECRET} \
  -e BW_CLIENTSECRET=${BW_CLIENTSECRET} \
  -e MASTER_PASSWORD=${MASTER_PASSWORD} \
  -e ENCRYPTION_KEY=${ENCRYPTION_KEY} \
  -v /path/to/data/:/data/ \
  --restart unless-stopped \
  zicstardust/bitwarden-backup:latest
```

## Environment variables

| variables | Function | Default |
| :----: | --- | --- |
| `TZ` | Set Timezone | |
| `UID` | Set User ID | 1000 |
| `GID` | Set Group ID | 1000 |
| `INTERVAL` | interval between executions<br/><br/>examples:<br/><br/>`1d - 1 day`<br/><br/>`10m - 10 minutes`<br/><br/>`1w - 1 week`<br/><br/>`65s - 65 seconds` | 1d |
| `BW_SERVER` | Set Bitwarden Server | vault.bitwarden.com |
| `BW_CLIENTID` | Set User Client ID ||
| `BW_CLIENTSECRET` | Set User Client Secret ||
| `MASTER_PASSWORD` | Set User Master Password ||
| `ENCRYPTION_KEY` | Set password for file encryption ||
| `ORGANIZATION_IDS` | Backup organization vault<br/><br/>array separated by `,` ||
| `BACKUP_ORGANIZATION_ONLY` | Skip individual vault backup ||
| `KEEP_LAST` | Number of backups to keep<br/><br/>If value is 0, keep all | 0 |