#!/bin/bash

# ########################################
# Directories

WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSMGR_HOME="${WMSAPP_HOME}/manager"

# ########################################
# Manager/API credentials

DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=manager-credentials.sh
source "${DIR}/manager-credentials.sh"

# ########################################
# Startup script

"${WMSMGR_HOME}"/bin/startmgr.sh
