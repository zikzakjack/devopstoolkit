#!/bin/ksh

export ANT_HOME=/sbcimp/run/pd/jakarta-ant/1.7.0
export JAVA_HOME=/sbcimp/run/tp/oracle/client/v11.2.0.3-64bit/client_1/jdk
export ANT_OPTS="-Xmx1024m -Xms512m"

usage(){
	print "Usage: $0 -a <zikZakEnvName> -b <zikZakAppDir> -c <zikZakPkgsDir> -d <zikZakLogDir> -e <zikZakEnvProperties> -f <zikZakPasswordsFilePath>"
	exit
}

while getopts a:b:c:d:e:f: opt
do
	case $opt in
		a)
			zikZakEnvName=$OPTARG
		;;
		b)
			zikZakAppDir=$OPTARG
		;;
		c)
			zikZakPkgsDir=$OPTARG
		;;
		d)
			zikZakLogDir=$OPTARG
		;;
		e)
			zikZakEnvProperties=$OPTARG
		;;
		f)
			zikZakPasswordsFilePath=$OPTARG
		;;
		h)
			usage
		;;
	esac
done

shift `expr $OPTIND - 1` 

echo "========================================"
echo "Diagnostics: Values from Puppet Params"
echo "========================================"
echo "zikZakEnvName -> ${zikZakEnvName}"
echo "zikZakAppDir -> ${zikZakAppDir}"
echo "zikZakPkgsDir -> ${zikZakPkgsDir}"
echo "zikZakLogDir -> ${zikZakLogDir}"
echo "zikZakEnvProperties -> ${zikZakEnvProperties}"
echo "zikZakPasswordsFilePath -> ${zikZakPasswordsFilePath}"

if [ "X${zikZakEnvName}" == "X" ]; then 
	echo "No Environment has been specified" 
	usage 
	exit 1
fi 

if [ "X${zikZakAppDir}" == "X" ]; then 
	echo "No Application Directory has been specified" 
	usage 
	exit 1
fi 

if [ "X${zikZakPkgsDir}" == "X" ]; then 
	echo "No Packages Directory has been specified" 
	usage 
	exit 1
fi 

if [ "X${zikZakLogDir}" == "X" ]; then 
	echo "No Log Directory has been specified" 
	usage 
	exit 1
fi 

if [ "X${zikZakEnvProperties}" == "X" ]; then 
	echo "No environment specific properties file have been specified" 
	usage 
	exit 1
fi 

if [ "X${zikZakPasswordsFilePath}" == "X" ]; then 
	echo "No passwords file have been specified" 
	usage 
	exit 1
fi 

ZIKZAK_ENV=${zikZakEnvName}
ZIKZAK_ENV_LC=`echo ${zikZakEnvName} | tr '[:upper:]' '[:lower:]'`
APP_DIR=${zikZakAppDir}
PKG_DIR=${zikZakPkgsDir}
LOG_DIR=${zikZakLogDir}
LOG_DIR_SYMLINK=${APP_DIR}/logs

echo "========================================"
echo "Diagnostics: Current Folder Structure"
echo "========================================"
echo "VERSION -> ${project.version}"
echo "ZIKZAK_ENV -> ${ZIKZAK_ENV}"
echo "ZIKZAK_ENV_LC -> ${ZIKZAK_ENV_LC}"
echo "APP_DIR -> ${APP_DIR}"
echo "PKG_DIR -> ${PKG_DIR}"
echo "LOG_DIR -> ${LOG_DIR}"
echo "LOG_DIR_SYMLINK -> ${LOG_DIR_SYMLINK}"
echo "PWD -> `pwd`"

${ANT_HOME}/bin/ant -buildfile postDeploy.xml postDeploy -DzikZakEnvName=$zikZakEnvName -DzikZakAppDir=$zikZakAppDir -DzikZakPkgsDir=$zikZakPkgsDir -DzikZakLogDir=$zikZakLogDir -DzikZakEnvProperties=$zikZakEnvProperties -DzikZakPasswordsFilePath=$zikZakPasswordsFilePath -Dversion=${project.version} -DzikZakEnvNameLC=$ZIKZAK_ENV_LC
status=$?
echo "Ant build completed, status=[${status}]"

if [ $status -ne 0 ]; then
	echo "========================================"
	echo "Ant build failed, status=[${status}] Please check..."
	echo "========================================"
	exit 1
elif [ $status -eq 0 ]; then
	echo "Clean up the installation"
	rm -rf ${PKG_DIR}/*.gz
	rm -rf ${PKG_DIR}/tmp/
fi

cd ${APP_DIR}/

echo "Deleting the symlink -> ${LOG_DIR_SYMLINK}"
if [ -e ${LOG_DIR_SYMLINK} ]; then
	rm ${LOG_DIR_SYMLINK}
fi

echo "Creating the symlink -> ${LOG_DIR_SYMLINK} -> ${LOG_DIR}"
mkdir -p ${LOG_DIR}
ln -s ${LOG_DIR} ${LOG_DIR_SYMLINK}

echo "========================================"
echo "Configuration Completed..."
echo "========================================"
