#!/bin/bash

################################################################################
# Configure Application Metadata
################################################################################

APP_NAME=ZikZakJack
APP_PID_FILE_NAME=zikzakjack.pid
APP_SERVICE_NAME_SUFFIX=ZIKZAKJACK
APP_MAIN_CLASS=com.MyLauncher

################################################################################
# Configure the properties used for jvm startup
################################################################################

KEY_ZIKZAKJACK_ENV=zikzakjack.environment
KEY_ZIKZAKJACK_APP_VERSION=zikzakjack.app.version
KEY_APP_DIR=dir.app.zikzakjack
KEY_APP_LOG_DIR=dir.log.zikzakjack
KEY_APP_LOG_FILE=log.file
KEY_MEMORY_PARAMS=java.heap.params.zikzakjack
KEY_GC_PARAMS=java.gc.params.zikzakjack
KEY_RUNTIME_PARAMS=java.runtime.params.zikzakjack
KEY_AD_ENABLE=appdynamics.enable
KEY_AD_AGENT_PATH=appdynamics.agent.path
KEY_AD_AGENT_APPNAME=appdynamics.agent.applicationName
KEY_AD_AGENT_TIERNAME=appdynamics.agent.tierName
KEY_AD_AGENT_NODENAME=appdynamics.agent.nodeName.zikzakjack

APP_RUNNER=$(readlink -f $0)
APP_BIN=`dirname ${APP_RUNNER}`
APP_CONF_DIR=$(readlink -f ${APP_BIN}/../config/)
APP_PID_FILE=${APP_BIN}/${APP_PID_FILE_NAME}

################################################################################
# Functions : start|stop|restart|check
################################################################################

start() {
	if [ $( checkPid ) == 0 ]; then
		echo "${APP_NAME} is already running, pid="$( getProcessId )
	else
		echo "Starting ${APP_NAME} !!!"
		printf
		echo "java -classpath ${CLASSPATH} ${VMARGS} ${APP_MAIN_CLASS} ${APP_NAME}"
		java -classpath ${CLASSPATH} ${VMARGS} ${APP_MAIN_CLASS} ${APP_NAME} >> /dev/null 2>&1 &
		echo $! > ${APP_PID_FILE}
		sleep 10
		if [ $( checkPid ) == 0 ]; then
			echo "${APP_NAME} is started now. pid="$( getProcessId )
			exit 0
		else
			echo "${APP_NAME} is not started. Please check the problem"
			exit 1
		fi	
	fi
}

stop() {
	if [ $( checkPid ) == 0 ]; then
		local pid=$( getProcessId )
		echo "Shutting down ${APP_NAME}. pid=${pid}"
		kill -15 ${pid}
		sleep 30
		if [ $( checkPid ) == 0 ]; then
			echo "Trouble Shutting down ${APP_NAME}. pid=${pid}. Please check..."
			exit 1
		else
			if [ -e ${APP_PID_FILE} ]; then
				rm ${APP_PID_FILE}
			fi
			echo "${APP_NAME} is stopped now . . ."
		fi
	else
		echo "${APP_NAME} is already NOT running."
	fi
}

restart() {
	stop
	start
}

check() {
	if [ $( checkPid ) == 0 ]; then
		echo "${APP_NAME} is Running. pid="$( getProcessId )
		exit 0
	else
		echo "${APP_NAME} is NOT running."
		exit 1
	fi
}

checkPid() {
	if [[ $( checkProcessById ) == 0 || $( checkProcessByName ) == 0 ]]; then
		pidExists=0
	else
		pidExists=1
	fi
	echo "${pidExists}"
}

checkProcessById() {
	if [ -e ${APP_PID_FILE} ]; then
		APP_PID=$( getProcessIdFromFile )
		PROCESSNAME=`/bin/ps auxwww | /bin/grep ${APP_PID} | grep -v grep`
		if [[ "${PROCESSNAME// }" != "" ]]; then
			processNameExists=0
		else
			processNameExists=1
		fi
	else
		processNameExists=1
	fi
	echo "${processNameExists}"
}

checkProcessByName() {
	PROCESSID=$( getProcessIdFromCmd )
	if [[ "${PROCESSID// }" != "" ]]; then
		processIdExists=0
	else
		processIdExists=1
	fi
	echo "${processIdExists}"
}

getProcessId() {
		if [ -e ${APP_PID_FILE} ]; then
			processId=$( getProcessIdFromFile )
		else
			processId=$( getProcessIdFromCmd )
		fi
	echo "${processId// }"
}

getProcessIdFromFile() {
	echo `cat ${APP_PID_FILE}`
}

getProcessIdFromCmd() {
	echo `/bin/ps auxwww | /bin/grep ${APP_SERVICE} | grep -v grep | /bin/awk "{print \\$2}"`
}

printf() {
	echo "================================================================================"
	echo "ZIKZAKJACK_ENV -> ${ZIKZAKJACK_ENV}"
	echo "VERSION -> ${ZIKZAKJACK_APP_VERSION}"
	echo "APP_DIR -> ${APP_DIR}"
	echo "VMARGS=\${MEMORY_PARAMS} \${GC_PARAMS} \${RUNTIME_PARAMS} \${AD_AGENT_OPTS} "
	echo "MEMORY_PARAMS -> ${MEMORY_PARAMS}"
	echo "GC_PARAMS -> ${GC_PARAMS}"
	echo "RUNTIME_PARAMS -> ${RUNTIME_PARAMS}"
	echo "AD_AGENT_OPTS -> ${AD_AGENT_OPTS}"
	echo "================================================================================"
}

getProperty() {
	local value=`grep "${1}" "${APP_CONF}" | cut -d '=' -f2- | head -n1`
	echo "${value}"
}

getAppDynamicsArgs() {
	### Enable AppDynamics Configurations only if the flag is set
	local AD_AGENT_OPTS=""
	if [ "${AD_ENABLE}" == "true" ] 
	then
		if [[ "${AD_AGENT_PATH}" != "" && "${AD_AGENT_APPNAME}" != ""  && "${AD_AGENT_TIERNAME}" != ""  && "${AD_AGENT_NODENAME}" != "" ]]; then
			AD_AGENT_OPTS=" -javaagent:${AD_AGENT_PATH} -Dappdynamics.agent.applicationName=${AD_AGENT_APPNAME} -Dappdynamics.agent.tierName=${AD_AGENT_TIERNAME} -Dappdynamics.agent.nodeName=${AD_AGENT_NODENAME} "
			if [ -e ${AD_AGENT_PATH} ]; then
				echo "${AD_AGENT_OPTS}"
			else
				echo "AppDynamics Agent Path is invalid. Please check..."
				exit 1;
			fi
		else
			echo "AppDynamics is enabled, but the Configurations are not set properly in properties file ${APP_CONF}. Please check..."
			exit 1
		fi
	fi 
}

usage() {
	echo
	echo "Usage: $0 {start|stop|restart|check}"
	echo
}

if [ "$#" == "0" ]; then 
	usage 
	exit 1
fi 

################################################################################
# Read the environment specific properties file in the bin 
################################################################################

APP_CONF=$(find ${APP_CONF_DIR} -name "zikzakjack-*.properties" -exec printf {} ';')
if [ ! -f "${APP_CONF}" ]; then
	echo "Error: [$APP_CONF] does not exist!!"
	exit 1
fi
echo "${APP_NAME} Reading Properties file ${APP_CONF}"

ZIKZAKJACK_ENV=$( getProperty ${KEY_ZIKZAKJACK_ENV})
ZIKZAKJACK_ENV_LC="${ZIKZAKJACK_ENV,,}"
ZIKZAKJACK_APP_VERSION=$( getProperty ${KEY_ZIKZAKJACK_APP_VERSION})
APP_DIR=$( getProperty ${KEY_APP_DIR})
APP_LOG_DIR=$( getProperty ${KEY_APP_LOG_DIR})
APP_LOG_FILE=$( getProperty ${KEY_APP_LOG_FILE})
MEMORY_PARAMS=$( getProperty ${KEY_MEMORY_PARAMS})
GC_PARAMS=$( getProperty ${KEY_GC_PARAMS})
RUNTIME_PARAMS=$( getProperty ${KEY_RUNTIME_PARAMS})
RUNTIME_PARAMS=" ${RUNTIME_PARAMS} -DCONFIG_DIR=${APP_CONF_DIR}/ -DENV=${ZIKZAKJACK_ENV_LC} -DLOG_FILE=${APP_LOG_FILE} "
AD_ENABLE=$( getProperty ${KEY_AD_ENABLE})
AD_AGENT_PATH=$( getProperty ${KEY_AD_AGENT_PATH})
AD_AGENT_APPNAME=$( getProperty ${KEY_AD_AGENT_APPNAME})
AD_AGENT_TIERNAME=$( getProperty ${KEY_AD_AGENT_TIERNAME})
AD_AGENT_NODENAME=$( getProperty ${KEY_AD_AGENT_NODENAME})
AD_AGENT_OPTS=$( getAppDynamicsArgs )
VMARGS="${MEMORY_PARAMS} ${GC_PARAMS} ${RUNTIME_PARAMS} ${AD_AGENT_OPTS} "

################################################################################
# Set up the environment
################################################################################

JAVA_HOME=/sbcimp/run/tp/sun/jre/v1.8.0_45-64bit
APP_CLASSPATH=$(find ${APP_DIR}/ -maxdepth 1 -name "*.jar" -exec printf :{} ';')
APP_SERVICE="ZIKZAKJACK_APPS_${ZIKZAKJACK_ENV}_${APP_SERVICE_NAME_SUFFIX}"
PATH=${JAVA_HOME}/bin:$PATH
CLASSPATH=${APP_SERVICE}:${APP_CONF_DIR}/:${APP_CLASSPATH}

################################################################################
# Evaluate the Command
################################################################################

cmd=$1
case "$cmd" in
	start)
		start
		exit 0
	;;
	stop)
		stop
		exit 0
	;;
	restart)
		restart
		exit 0
	;;
	check)
		check
	;;
	*)
	usage
	exit 1
esac

exit 0
