#!/usr/bin/env bash

# ############################################################
# Read all Docker secrets in /run/secrets and set them as
# environment variables corresponding to the secret file name.
#
# Note that for these variables to be exported to the calling
# script, this script must be invoked with `source` rather
# than called directly.
# ############################################################

BASENAME=$(basename ${BASH_SOURCE})
echo "${BASENAME} running"

if [ -d '/run/secrets' ]; then
  for f in /run/secrets/*
  do
    SECRET="$(basename "${f}")"
    echo "Setting ${SECRET} from ${f}"
    export "${SECRET}"="$(cat "${f}")"
  done
fi
