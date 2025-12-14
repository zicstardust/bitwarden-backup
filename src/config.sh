#!/usr/bin/env bash
CheckVariables() {
    if ! [ "${BW_CLIENTID}" ]; then
        echo -e "${RED}BW_CLIENTID not set."
        exit 1
    fi


    if ! [ "${BW_CLIENTSECRET}" ]; then
        echo -e "${RED}BW_CLIENTSECRET not set."
        exit 1
    fi


    if ! [ "${BW_PASSWORD}" ]; then
        echo -e "${RED}BW_PASSWORD not set."
        exit 1
    fi

    if ! [ "${ENCRYPTION_KEY}" ] && [ "${BACKUP_FORMAT}" ==  "encrypted_json" ]; then
        echo -e "${RED}ENCRYPTION_KEY not set."
        exit 1
    fi


    if [ "${BACKUP_FORMAT}" !=  "encrypted_json" ] && [ "${BACKUP_FORMAT}" !=  "json" ] && [ "${BACKUP_FORMAT}" !=  "csv" ]; then
        echo -e "${RED}Invalid BACKUP_FORMAT."
        exit 1
    fi


    re='^[0-9]+$'
    if ! [[ $KEEP_LAST =~ $re ]] ; then
        echo -e "${RED}Invalid KEEP_LAST"
        exit 1
    fi
}


SetURLServer(){
    if ! [ "${BW_SERVER_BASE}" ]; then
        return
    fi
    
    local BW_SERVER=$BW_SERVER_BASE
    
    if [ "${BW_SERVER_WEB_VAULT}" ]; then
        BW_SERVER="$BW_SERVER --web-vault $BW_SERVER_WEB_VAULT"
    fi

    if [ "${BW_SERVER_API}" ]; then
        BW_SERVER="$BW_SERVER --api $BW_SERVER_API"
    fi

    if [ "${BW_SERVER_IDENTITY}" ]; then
        BW_SERVER="$BW_SERVER --identity $BW_SERVER_IDENTITY"
    fi

    if [ "${BW_SERVER_ICONS}" ]; then
        BW_SERVER="$BW_SERVER --icons $BW_SERVER_ICONS"
    fi

    if [ "${BW_SERVER_NOTIFICATIONS}" ]; then
        BW_SERVER="$BW_SERVER --notifications $BW_SERVER_NOTIFICATIONS"
    fi

    if [ "${BW_SERVER_EVENTS}" ]; then
        BW_SERVER="$BW_SERVER --events $BW_SERVER_EVENTS"
    fi

    if [ "${BW_SERVER_KEY_CONNECTOR}" ]; then
        BW_SERVER="$BW_SERVER --key-connector $BW_SERVER_KEY_CONNECTOR"
    fi

    bw config server ${BW_SERVER} 1> /dev/null
}


Login() {
    echo "Logging in..."
    bw login --apikey 1> /dev/null
}

Unlock() {
    echo -e "Unlocking vault...\n"
    BW_SESSION=$(bw unlock "$MASTER_PASSWORD" --raw)
}

Lock() {
    echo -e "\nLocking vault..."
    bw lock 1> /dev/null
}
