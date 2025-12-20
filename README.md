# Bitwarden automatic backup container

[GitHub](https://github.com/zicstardust/bitwarden-backup)

## Container
### Tags

| Tag | Architecture | Description |
| :----: | :----: | :----: |
| [`latest`](https://github.com/zicstardust/bitwarden-backup/blob/main/dockerfile) | amd64 | Bitwarden CLI Node version |

### Registries
| Registry | Full image name | Description |
| :----: | :----: | :----: |
| [`docker.io`](https://hub.docker.com/r/zicstardust/bitwarden-backup) | `docker.io/zicstardust/bitwarden-backup` | Docker Hub |
| [`ghcr.io`](https://github.com/zicstardust/bitwarden-backup/pkgs/container/bitwarden-backup) | `ghcr.io/zicstardust/bitwarden-backup` | GitHub |


## Usage
### Compose
```
services:
  bitwarden-backup:
    container_name: bitwarden-backup
    image: docker.io/zicstardust/bitwarden-backup:latest
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
      INTERVAL: 1d
      BW_CLIENTID: ${BW_CLIENTID}
      BW_CLIENTSECRET: ${BW_CLIENTSECRET}
      BW_PASSWORD: ${BW_PASSWORD}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
    volumes:
      - <path to data>:/data/
```


## Environment variables

| variables | Function | Default |
| :----: | --- | --- |
| `TZ` | Set Timezone | |
| `PUID` | Set User ID | 1000 |
| `PGID` | Set Group ID | 1000 |
| `INTERVAL` | interval between executions<br/><br/>examples:<br/><br/>`1d - 1 day`<br/><br/>`10m - 10 minutes`<br/><br/>`1w - 1 week`<br/><br/>`65s - 65 seconds` | 1d |
| `BW_CLIENTID` | Set User Client ID ||
| `BW_CLIENTSECRET` | Set User Client Secret ||
| `BW_PASSWORD` | Set User Master Password ||
| `ENCRYPTION_KEY` | Set password for file encryption ||
| `ORGANIZATION_IDS` | Backup organization vault<br/><br/>array separated by `,` ||
| `BACKUP_ORGANIZATION_ONLY` | Set `1` to skip individual vault backup | |
| `KEEP_LAST` | Number of backups to keep<br/><br/>If value is 0, keep all | 0 |
| `BACKUP_FORMAT` | export backup format<br/><br/>options: `encrypted_json`, `json`, `csv`<br/><br/>IMPORTANT: Only `encrypted_json` is encrypted and requires `ENCRYPTION_KEY` | encrypted_json |

### For Self-hosted only

| variables | Function | Required |
| :----: | --- | --- |
| `BW_SERVER_BASE` | On-premises hosted installation URL | Required |
| `BW_SERVER_WEB_VAULT` | Custom web vault URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_API` | Custom API URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_IDENTITY` | Custom identity URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_ICONS` | Custom icons service URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_NOTIFICATIONS` | Custom notifications URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_EVENTS` | Custom events URL that differs from the `BW_SERVER_BASE` | Optional |
| `BW_SERVER_KEY_CONNECTOR` | URL for your Key Connector server | Optional |
