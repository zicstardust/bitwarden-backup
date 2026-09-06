#!/usr/bin/env bash

source /usr/local/bin/backup.sh
source /usr/local/bin/config.sh
source /usr/local/bin/utils.sh

set -e

: "${INTERVAL:=1d}"
: "${KEEP_LAST:=0}"
: "${BACKUP_FORMAT:=encrypted_json}"

export INTERVAL KEEP_LAST BACKUP_FORMAT

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
rm -f /config/data.json
touch /config/data.json
echo -e "${BACKGROUND_BLUE}Bitwarden CLI $(bw --version)${NOCOLOR}"
Config

while true; do
    Backup

    echo "Next execution: $INTERVAL"
    sleep "$INTERVAL"
done
