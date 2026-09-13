#!/bin/bash

set -e

: "${PUID:=1000}"
: "${PGID:=1000}"

if [ "$PUID" != "$(id -u bwbackup)" ]; then
  usermod -u "$PUID" bwbackup
fi

if [ "$PGID" != "$(id -g bwbackup)" ]; then
  groupmod -g "$PGID" bwbackup
fi

mkdir -p /data /config

chown -R bwbackup:bwbackup /data /config /home/bwbackup

exec su-exec bwbackup "$@"
