#!/bin/bash

# ############################################################
# Global configuration

WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSMGR_HOME="${WMSAPP_HOME}/manager"

# ############################################################
# Validation

# We don't strictly need this, but if it wasn't passed in, the
# server's just going to keep restarting

if [ -z "${WSE_MGR_PASS}" ]; then
  echo 'Wowza Streaming Engine Manager password not set in WSE_MGR_PASS'
  exit 1
fi

# ############################################################
# Startup script

"${WMSMGR_HOME}"/bin/startmgr.sh
