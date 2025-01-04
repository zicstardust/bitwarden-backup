#!/bin/bash
#config server
DATE=$(date "+%Y%m%d-%H%M%S")

if [[ -z "$CLIENT_ID" ]]; then
   echo "CLIENT_ID not set"
   exit 1
fi


if [[ -z "$CLIENT_SECRET" ]]; then
   echo "CLIENT_SECRET not set"
   exit 1
fi


if [[ -z "$MASTER_PASSWORD" ]]; then
   echo "MASTER_PASSWORD not set"
   exit 1
fi


if [[ -z "$ENCRYPTION_KEY" ]]; then
   echo "ENCRYPTION_KEY not set"
   exit 1
fi

status=$(/app/bw status)

if ! [ $(echo $status | grep $BW_SERVER) ]; then
   /app/bw config server $BW_SERVER
fi

#login
userID=$(echo $CLIENT_ID | sed 's/^user.//')
if ! [ $(echo $status | grep $userID) ]; then
   BW_CLIENTID=${CLIENT_ID} \
   BW_CLIENTSECRET=${CLIENT_SECRET} \
   /app/bw login --apikey
fi
#get session
BW_SESSION=$(/app/bw unlock --raw $MASTER_PASSWORD)

#backup
/app/bw --raw --session $BW_SESSION \
export --format encrypted_json \
--password $ENCRYPTION_KEY \
> /data/bitwarden-backup-$DATE.json

chown bitwarden:bitwarden /data/bitwarden-backup-$DATE.json

#logout
#/app/bw logout
#echo "" > "/home/bitwarden/.config/Bitwarden CLI/data.json"

echo ""
echo "next execution in $INTERVAL"
sleep $INTERVAL
exec "$0" "$@"