#!/usr/bin/env bash


#Color Output
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m' 
BACKGROUND_BLUE='\x1b[44m'
NOCOLOR='\x1b[0m'


DateTimeNow() {
    date "+%Y.%m.%d-%H:%M:%S"
}


BackupExtension(){

    if [ "${BACKUP_FORMAT}" ==  "encrypted_json" ] || [ "${BACKUP_FORMAT}" ==  "json" ]; then
        echo "json"
    elif [ "${BACKUP_FORMAT}" ==  "csv" ]; then
        echo "csv"
    fi

}


RemoveOldBackups(){
    local name_filter=$1

    if [ "${KEEP_LAST}" ==  "0" ]; then
        echo -e "${YELLOW}KEEP_LAST=0, keeping all backups${NOCOLOR}"
        return
    fi

    local files_list=($(ls /data/*${name_filter}*))

    if [ ${#files_list[@]} -gt $KEEP_LAST ]; then
        local delete_files_length=$((${#files_list[@]}-$KEEP_LAST))

        local i=0
        for file in "${files_list[@]}"; do
            rm -f $file
            echo -e "${RED}deleted: $file${NOCOLOR}"
            i=$(($i+1))
            if [ $i -eq $delete_files_length ]; then
                break
            fi
        done

    else
        echo -e "${YELLOW}No delete old backup, number of backups less than KEEP_LAST${NOCOLOR}"
    fi
}
