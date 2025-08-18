#!/bin/sh

set -e

if [ "$PUID" != "$(id -u node)" ]; then
  usermod -u "$PUID" node
fi

if [ "$PGID" != "$(id -g node)" ]; then
  groupmod -g "$PGID" node
fi

chown -R node:node /data /app

exec su-exec node "$@"
