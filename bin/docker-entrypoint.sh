#!/usr/bin/env bash

# ############################################################
# Starts the Wowza Streaming Media Engine and the Wowza
# Streaming Media Engine Manager in subprocesses, and waits
# for them to exit.

BASENAME=$(basename ${BASH_SOURCE})
echo "${BASENAME} running"

# ########################################
# Global configuration

WOWZA_BIN="$(dirname "${BASH_SOURCE[0]}")"
WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSMGR_HOME="${WMSAPP_HOME}/manager"

# ########################################
# Documentation server (disabled by default)

if [ ! -z "${WOWZA_ENABLE_DOCUMENTATION_SERVER}" ]; then
  "${WOWZA_BIN}"/enable-documentation-server.sh
fi

# load secrets into wowza env vars. by default, the Wowza entrypoint
# creates the keyfile in question, which is why we pass the variable
# in using a different name.
. "${WOWZA_BIN}/secrets.sh"

export WSE_MGR_USER=$WOWZA_MANAGER_USER
export WSE_MGR_PASS=$WOWZA_MANAGER_PASSWORD
export WSE_LIC=$WOWZA_LICENSE_KEY

# ########################################
# Start server and manager by handing off to Wowza's entrypoint

echo Invoking Wowza\'s /sbin/entrypoint.sh
exec /sbin/entrypoint.sh "$@"
