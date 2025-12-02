#!/bin/bash
# this is a BerkeleyLibrary modified version of the WSE startup script

# check for root access. If not, put up message and exit
# if [ "$(/usr/bin/id -u)" -ne "0" ] ; then
#     echo "The Wowza Streaming Engine requires root access to start. Please run script again using sudo."
#     exit
# fi

systemctl >> /dev/null 2>&1
if [ $? -eq 0 ]; then
	# Restart XRM service
	SERVICE_NAME="xrmd.service"
	systemctl list-units --full -all | grep -Fq $SERVICE_NAME

	if [ $? -eq 0 ]; then
		echo "Restarting XRM service"
		systemctl restart $SERVICE_NAME
		. /opt/xilinx/xcdr/setup.sh
	fi
fi

. /usr/local/WowzaStreamingEngine/bin/setenv.sh
mode=standalone
if [ "$#" -eq 1 ];
then
mode=$1
fi

#chmod 600 /usr/local/WowzaStreamingEngine/conf/jmxremote.password
#chmod 600 /usr/local/WowzaStreamingEngine/conf/jmxremote.access

# NOTE: Here you can configure the JVM's built in JMX interface.
# See the "Server Management Console and Monitoring" chapter
# of the "User's Guide" for more information on how to configure the
# remote JMX interface in the [install-dir]/conf/Server.xml file.

JMXOPTIONS=-Dcom.sun.management.jmxremote=true
#JMXOPTIONS="$JMXOPTIONS -Djava.rmi.server.hostname=192.168.1.7"
#JMXOPTIONS="$JMXOPTIONS -Dcom.sun.management.jmxremote.port=1099"
#JMXOPTIONS="$JMXOPTIONS -Dcom.sun.management.jmxremote.authenticate=true"
#JMXOPTIONS="$JMXOPTIONS -Dcom.sun.management.jmxremote.ssl=false"
#JMXOPTIONS="$JMXOPTIONS -Dcom.sun.management.jmxremote.password.file=$WMSCONFIG_HOME/conf/jmxremote.password"
#JMXOPTIONS="$JMXOPTIONS -Dcom.sun.management.jmxremote.access.file=$WMSCONFIG_HOME/conf/jmxremote.access"

ulimit -n 64000 > /dev/null 2>&1

rc=144
while [ $rc -eq 144 ]
do

WMSTUNE_OPTS=`$WMSAPP_HOME/bin/tune.sh $mode`
export LD_PRELOAD=`$WMSAPP_HOME/bin/ldpreload.sh`

# log interceptor com.wowza.wms.logging.LogNotify - see Javadocs for ILogNotify

$_EXECJAVA $WMSTUNE_OPTS $JMXOPTIONS -Dorg.slf4j.simpleLogger.defaultLogLevel=warn -Dcom.wowza.wms.runmode="$mode" -Dcom.wowza.wms.native.base="linux" -Dlog4j.configurationFile="$WMSCONFIG_HOME/conf/log4j2-config.xml" -Dcom.wowza.wms.AppHome="$WMSAPP_HOME" -Dcom.wowza.wms.ConfigURL="$WMSCONFIG_URL" -Dcom.wowza.wms.ConfigHome="$WMSCONFIG_HOME" -cp $WMSAPP_HOME/bin/wms-bootstrap.jar com.wowza.wms.bootstrap.Bootstrap start

rc=$?
if [ $rc -ge 10 ] && [ $rc -le 15 ] ; then
    WSE_EXIT_CODE=$rc
    $_EXECJAVA $WMSTUNE_OPTS $JMXOPTIONS -Dcom.wowza.wms.runmode="$mode" -Dcom.wowza.wms.native.base="linux" -Dlog4j.configurationFile="$WMSCONFIG_HOME/conf/log4j2-config.xml" -Dcom.wowza.wms.AppHome="$WMSAPP_HOME" -Dcom.wowza.wms.ConfigURL="$WMSCONFIG_URL" -Dcom.wowza.wms.ConfigHome="$WMSCONFIG_HOME" -cp $WMSAPP_HOME/bin/wms-bootstrap.jar com.wowza.wms.bootstrap.Bootstrap startLicenseUpdateServer
    rc=$?
fi
done
