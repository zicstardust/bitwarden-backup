#!/usr/bin/env bash

source /usr/local/bin/backup.sh
source /usr/local/bin/config.sh
source /usr/local/bin/utils.sh

set -e

: "${INTERVAL:=1d}"
: "${KEEP_LAST:=0}"
: "${BACKUP_FORMAT:=encrypted_json}"


Config() {
    CheckVariables
    SetURLServer
    Login
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
