#!/bin/bash

set -e

: "${PUID:=1000}"
: "${PGID:=1000}"

if [ "$PUID" != "$(id -u node)" ]; then
  usermod -u "$PUID" node
fi

if [ "$PGID" != "$(id -g node)" ]; then
  groupmod -g "$PGID" node
fi

chown -R node:node /data /app

exec su-exec node "$@"
