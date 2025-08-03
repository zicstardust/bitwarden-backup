#!/bin/sh

set -e

if [ "$UID" != "$(id -u node)" ]; then
  usermod -u "$UID" node
fi

if [ "$GID" != "$(id -g node)" ]; then
  groupmod -g "$GID" node
fi

chown -R node:node /data /app

exec su-exec node "$@"
