#!/bin/bash
set -e

if [ "$SEED_SERVER" ]; then
  if [ ! -e /opt/factorio/saves/savegame.zip ]; then
    /opt/factorio/bin/x64/factorio --create savegame
  fi
fi
exec "$@" #/opt/factorio/bin/x64/factorio --start-server savegame
