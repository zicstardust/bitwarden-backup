# Docker automatic bitwarden backup

```
services:
  bitwarden-backup:
    container_name: bitwarden-backup
    image: zicstardust/bitwarden-backup:latest
    environment:
      TZ: America/New_York
      UID: 1000
      GID: 1000
      INTERVAL: 24h
      BW_SERVER: ${BW_SERVER}
      CLIENT_ID: ${CLIENT_ID}
      CLIENT_SECRET: ${CLIENT_SECRET}
      MASTER_PASSWORD: ${MASTER_PASSWORD}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
      
    volumes:
      - /path/to/data/:/data/
```