#!/usr/bin/env bash

source /app/backup.sh
source /app/config.sh
source /app/utils.sh

set -e

: "${INTERVAL:=1d}"
: "${KEEP_LAST:=0}"
: "${BACKUP_FORMAT:=encrypted_json}"


Config() {
    CheckVariables
    SetURLServer
    Login
    unset BW_CLIENTID
    unset BW_CLIENTSECRET
    MASTER_PASSWORD=$BW_PASSWORD
    unset BW_PASSWORD
}


Backup() {
    Unlock
    BackupPersonalVault
    BackupOrganizationVault
    unset BW_SESSION
    Lock
}


#Main
echo -e "${BACKGROUND_BLUE}Bitwarden CLI $(bw --version)${NOCOLOR}"
Config

while true; do
    Backup

    echo "Next execution: $INTERVAL"
    sleep "$INTERVAL"
done
