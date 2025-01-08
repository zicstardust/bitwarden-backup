# Docker automatic bitwarden backup

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
      #ORGANIZATION_ID: #Optional
      #BACKUP_ORGANIZATION_ONLY: "False" #Optional
      #KEEP_LAST: 7
    volumes:
      - /path/to/data/:/data/
```
