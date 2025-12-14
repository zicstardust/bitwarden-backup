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
    MASTER_PASSWORD=$BW_PASSWORD
    unset BW_PASSWORD
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
Config

while true; do
    Backup

    echo "Next execution: $INTERVAL"
    sleep "$INTERVAL"
done
