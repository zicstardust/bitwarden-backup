#!/usr/bin/env bash
BackupPersonalVault() {

    if [ "${BACKUP_ORGANIZATION_ONLY}" == "1" ]; then
        echo -e "${YELLOW}BACKUP_ORGANIZATION_ONLY set, skip individual vault backup..."
        return
    fi
    local now
    now=$(DateTimeNow)

    local FILENAME="${now}_bitwarden-backup.$(BackupExtension)"


    if [ "${BACKUP_FORMAT}" == "encrypted_json" ]; then
        backup_content=$(bw --raw --session ${BW_SESSION} export --format encrypted_json --password ${ENCRYPTION_KEY})
    else
        backup_content=$(bw --raw --session ${BW_SESSION} export --format ${BACKUP_FORMAT})
    fi

    echo "$backup_content" > /data/${FILENAME}
    echo -e "${GREEN}Backup individual vault done: ${FILENAME}"
    RemoveOldBackups "bitwarden-backup"
}


BackupOrganizationVault() {
    if ! [ "${ORGANIZATION_IDS}" ]; then
        return
    fi

    IFS=',' read -ra ORGS <<< "$ORGANIZATION_IDS"

    for org in "${ORGS[@]}"; do

        local now
        now=$(DateTimeNow)

        local FILENAME="${now}_ORG_${org}.$(BackupExtension)"


        if [ "${BACKUP_FORMAT}" == "encrypted_json" ]; then
            backup_content=$(bw --raw --session ${BW_SESSION} export --organizationid ${org} --format encrypted_json --password ${ENCRYPTION_KEY})
        else
            backup_content=$(bw --raw --session ${BW_SESSION} export --organizationid ${org} --format ${BACKUP_FORMAT})
        fi

        echo "$backup_content" > /data/${FILENAME}
        echo -e "${GREEN}Backup organization vault done: ${FILENAME}"
        RemoveOldBackups "ORG_${org}"

    done
}
