#!/bin/bash

# ############################################################
# Verify that we have credentials for the Wowza Streaming
# Engine Manager and REST API, provided via $WOWZA_MANAGER_USER
# $WOWZA_MANAGER_PASSWORD environment variables, or
# corresponding Docker secrets.
#
# If $WOWZA_MANAGER_USER is not set, we set it to a default
# value; if $WOWZA_MANAGER_PASSWORD is not set, we exit with
# an error.
#
# Note that for these variables to be exported to the calling
# script, this script must be invoked with `source` rather
# than called directly.
# ############################################################

# Read secrets
DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=secrets.sh
source "${DIR}/secrets.sh"

# Default WOWZA_MANAGER_USER to 'wowza' if not set
: "${WOWZA_MANAGER_USER:=wowza}"

# Verify WOWZA_MANAGER_PASSWORD set
if [ -z "${WOWZA_MANAGER_PASSWORD}" ]; then
  echo 'Wowza Streaming Engine Manager password not set in WOWZA_MANAGER_PASSWORD'
  exit 1
fi
