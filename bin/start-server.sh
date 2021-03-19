#!/usr/bin/env bash

# ############################################################
# Starts the Wowza Streaming Engine.

BASENAME=$(basename ${BASH_SOURCE})
echo "${BASENAME} running"

# ########################################
# Global configuration

WOWZA_BIN="$(dirname "${BASH_SOURCE[0]}")"
WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSAPP_CONF="${WMSAPP_HOME}/conf"

# ########################################
# Manager & API username/password

# shellcheck source=manager-credentials.sh
source "${WOWZA_BIN}/manager-credentials.sh"

echo -e "\n${WOWZA_MANAGER_USER} ${WOWZA_MANAGER_PASSWORD} admin|advUser\n" > "${WMSAPP_CONF}/admin.password"
echo -e "\n${WOWZA_MANAGER_USER} ${WOWZA_MANAGER_PASSWORD}\n" > "${WMSAPP_CONF}/publish.password"
echo -e "\n${WOWZA_MANAGER_USER} ${WOWZA_MANAGER_PASSWORD}\n" > "${WMSAPP_CONF}/jmxremote.password"

# ########################################
# License file

WMSLICENSE_FILE="${WMSAPP_CONF}/Server.license"

if [ -z "${WOWZA_LICENSE_KEY}" ]; then
  # Container ships with some kind of demo license, so this isn't a showstopper?
  echo 'Wowza Streaming Engine license key not set in WOWZA_LICENSE_KEY'
else
  {
    echo '-----BEGIN LICENSE-----'
    echo "${WOWZA_LICENSE_KEY}"
    echo '-----END LICENSE-----'
  } > "${WMSLICENSE_FILE}"
fi

# ########################################
# Server startup

MODE=standalone

WMSJAVA_HOME="${WMSAPP_HOME}/java"
WMSTUNE_OPTS=$("${WMSAPP_HOME}/bin/tune.sh" ${MODE})
JMXOPTIONS="-Dcom.sun.management.jmxremote=true"
WMSAPP_BIN="${WMSAPP_HOME}/bin"

# shellcheck disable=SC2086
"${WMSJAVA_HOME}/bin/java" \
  ${WMSTUNE_OPTS} \
  ${JMXOPTIONS} \
  -Dcom.wowza.wms.runmode="${MODE}" \
  -Dcom.wowza.wms.native.base="linux" \
  -Dcom.wowza.wms.AppHome="${WMSAPP_HOME}" \
  -Dcom.wowza.wms.ConfigURL='' \
  -Dcom.wowza.wms.ConfigHome="${WMSAPP_HOME}" \
  -Dlog4j.configurationFile="${WMSAPP_CONF}/log4j2-config.xml" \
  -Dlog4j.garbagefreeThreadContextMap="true" \
  -cp "${WMSAPP_BIN}/wms-bootstrap.jar" \
  com.wowza.wms.bootstrap.Bootstrap \
  start
