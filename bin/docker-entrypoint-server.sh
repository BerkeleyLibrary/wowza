#!/bin/bash

# ############################################################
# Global configuration

WMSAPP_HOME="$(readlink /usr/local/WowzaStreamingEngine)"
WMSAPP_CONF="${WMSAPP_HOME}/conf"

# ############################################################
# Manager & API username/password

WSE_MGR_USER=wowza

if [ -z "${WSE_MGR_PASS}" ]; then
  echo 'Wowza Streaming Engine Manager password not set in WSE_MGR_PASS'
  exit 1
fi

echo -e "\n${WSE_MGR_USER} ${WSE_MGR_PASS} admin|advUser\n" >> "${WMSAPP_CONF}/admin.password"
echo -e "\n${WSE_MGR_USER} ${WSE_MGR_PASS}\n" >> "${WMSAPP_CONF}/publish.password"
echo -e "\n${WSE_MGR_USER} ${WSE_MGR_PASS}\n" >> "${WMSAPP_CONF}/jmxremote.password"

# ############################################################
# License file

WMSLICENSE_FILE="${WMSAPP_CONF}/Server.license"

if [ -z "${WSE_LIC}" ]; then
  # Container ships with some kind of demo license, so this isn't a showstopper?
  echo 'Wowza Streaming Engine license key not set in WSE_LIC'
else
  {
    echo '-----BEGIN LICENSE-----'
    echo "${WSE_LIC}"
    echo '-----END LICENSE-----'
  } > "${WMSLICENSE_FILE}"
fi

# ############################################################
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
  -cp "${WMSAPP_BIN}/wms-bootstrap.jar" \
  com.wowza.wms.bootstrap.Bootstrap \
  start
