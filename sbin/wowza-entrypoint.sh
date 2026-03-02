#!/bin/bash

# This is the Wowza entrypoint script as of 4.9.7+11; we're disabling
# the NVIDIA drivers because running ldconfig as an unprivileged user
# doesn't work.

# Begin Section to map NVIDIA specific libraries for EVA 

set -e

log() {
  echo "[entrypoint][$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

LIB_DIR="/usr/lib/x86_64-linux-gnu"

if [ -d "$LIB_DIR" ]; then
#   [ -f "${LIB_DIR}/libnvidia-encode.so.1" ] && \
#     ln -sf "${LIB_DIR}/libnvidia-encode.so.1" "${LIB_DIR}/libnvidia-encode.so"

#   [ -f "${LIB_DIR}/libnvcuvid.so.1" ] && \
#     ln -sf "${LIB_DIR}/libnvcuvid.so.1" "${LIB_DIR}/libnvcuvid.so"

#   ldconfig
#   log "NVIDIA symlinks installed, starting original service"
  	log "SKIPPING NVIDIA symlinks installation"

fi

# End Section to map NVIDIA specific libraries for EVA

WMSAPP_HOME="$( readlink /usr/local/WowzaStreamingEngine )"

if [ -z $WSE_MGR_USER ]; then
	mgrUser="wowza"
else
	mgrUser=$WSE_MGR_USER
fi
if [ -z $WSE_MGR_PASS ]; then
	mgrPass="wowza"
else
	mgrPass=$WSE_MGR_PASS
fi

if [ ! -z $WSE_LIC ]; then
cat > ${WMSAPP_HOME}/conf/Server.license <<EOF
-----BEGIN LICENSE-----
${WSE_LIC}
-----END LICENSE-----
EOF
fi

echo -e "\n$mgrUser $mgrPass admin|advUser\n" >> ${WMSAPP_HOME}/conf/admin.password
echo -e "\n$mgrUser $mgrPass\n" >> ${WMSAPP_HOME}/conf/publish.password
echo -e "\n$mgrUser $mgrPass\n" >> ${WMSAPP_HOME}/conf/jmxremote.password
#echo -e "$mgrUser readwrite\n" >> ${WMSAPP_HOME}/conf/jmxremote.access

if [[ ! -z $WSE_IP_PARAM ]]; then
	#change localhost to some user defined IP
	cat "${WMSAPP_HOME}/conf/Server.xml" > serverTmp
	sed 's|\(<IpAddress>localhost</IpAddress>\)|<IpAddress>'"$WSE_IP_PARAM"'</IpAddress> <!--changed for default install. \1-->|' <serverTmp >Server.xml
	sed 's|\(<RMIServerHostName>localhost</RMIServerHostName>\)|<RMIServerHostName>'"$WSE_IP_PARAM"'</RMIServerHostName> <!--changed for default install. \1-->|' <Server.xml >serverTmp
	cat serverTmp > ${WMSAPP_HOME}/conf/Server.xml
	rm serverTmp Server.xml
	
	cat "${WMSAPP_HOME}/conf/VHost.xml" > vhostTmp
	sed 's|\(<IpAddress>${com.wowza.wms.HostPort.IpAddress}</IpAddress>\)|<IpAddress>'"$WSE_IP_PARAM"'</IpAddress> <!--changed for default cloud install. \1-->|' <vhostTmp >${WMSAPP_HOME}/conf/VHost.xml 
	rm vhostTmp
fi

# Make supervisor log files configurable
#sed 's|^logfile=.*|logfile='"${SUPERVISOR_LOG_HOME}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
