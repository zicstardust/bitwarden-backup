#!/bin/bash
DATE=$(date "+%Y%m%d-%H%M%S")
FILENAME="${DATE}_bitwarden-backup.json"
FILENAME_ORG="${DATE}_ORG_${ORGANIZATION_ID}.json"

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

status=$(/usr/local/bin/bw status)

if ! [ $(echo $status | grep $BW_SERVER) ]; then
   /usr/local/bin/bw config server $BW_SERVER 1> /dev/null
fi

#login
userID=$(echo $CLIENT_ID | sed 's/^user.//')
if ! [ $(echo $status | grep $userID) ]; then
   BW_CLIENTID=${CLIENT_ID} \
   BW_CLIENTSECRET=${CLIENT_SECRET} \
   /usr/local/bin/bw login --apikey 1> /dev/null
fi
#get session
BW_SESSION=$(/usr/local/bin/bw unlock --raw $MASTER_PASSWORD)

#backup organization
if ! [[ -z "$ORGANIZATION_ID" ]]; then
   echo ""
   echo "Backup organization vault..."
   /usr/local/bin/bw --raw --session $BW_SESSION \
   export --organizationid $ORGANIZATION_ID --format encrypted_json \
   --password $ENCRYPTION_KEY \
   > /data/$FILENAME_ORG

   chown bitwarden:bitwarden /data/$FILENAME_ORG
fi


#backup
if [[ "$BACKUP_ORGANIZATION_ONLY" == "True" ]]; then
   echo "BACKUP_ORGANIZATION_ONLY is True, skip individual vault backup"
else
   echo "Backup individual vault..."
   /usr/local/bin/bw --raw --session $BW_SESSION \
   export --format encrypted_json \
   --password $ENCRYPTION_KEY \
   > /data/$FILENAME

   chown bitwarden:bitwarden /data/$FILENAME
fi

#logout
#/usr/local/bin/bw logout
#echo "" > "/home/bitwarden/.config/Bitwarden CLI/data.json"

echo ""
echo "next execution in $INTERVAL"
sleep $INTERVAL
exec "$0" "$@"