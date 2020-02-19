#!/bin/bash

# ########################################
# Directories

WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSMGR_HOME="${WMSAPP_HOME}/manager"

# ########################################
# Manager/API credentials

# Note that we don't really need these, but if they're
# not set, the server isn't going to start, and if it
# doesn't and we do, it's just going to keep restarting
# perpetually

DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=manager-credentials.sh
source "${DIR}/manager-credentials.sh"

# ########################################
# Startup script

"${WMSMGR_HOME}"/bin/startmgr.sh
