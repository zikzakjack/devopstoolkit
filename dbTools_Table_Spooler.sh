#!/bin/ksh

if [ "$#" -ne 4 ]; then
  echo
  echo "Usage: $0 dbUser dbPassword  tnsName dirPath "
  echo "dbUser => dbUser"
  echo "tnsName => tnsName"
  echo "dirPath => /somePath/datadir (provide any path where you have write access)"
  echo
  exit 1
fi

export ORACLE_HOME=/opt/oracle/client/v11.2.0.3-64bit/client_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=\$ORACLE_HOME/bin:$PATH

echo "ORACLE_HOME=${ORACLE_HOME}"
echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
echo "PATH=${PATH}"

# Assign the positional parameters appropriately
dbUser="$1"
dbPassword="$2"
tnsName="$3"
dirPath="$4"

echo "dbUser=${dbUser}"
echo "dbPassword=${dbPassword}"
echo "tnsName=${tnsName}"
echo "dirPath=${dirPath}"

${ORACLE_HOME}/bin/sqlplus -s ${dbUser}/${dbPassword}\@${tnsName} << EOF

SPOOL $dirPath/Employees.csv
SET COLSEP ","
SET DEFINE OFF
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET LINESIZE 50000
SET NEWPAGE NONE
SET PAGESIZE 0 
SET RECSEP WRAPPED
SET SERVEROUTPUT OFF
SET TERMOUT OFF
SET TRIMSPOOL ON
COL FREE FORMAT 9,999,999,999,999
COL TOTAL FORMAT 9,999,999,999,999

-- Concatinating commas in this fashion as I am not sure how to do it sqlplus native way. 
SELECT EMPLOYEE_ID||','||EMPLOYEE_FIRST_NAME||','||EMPLOYEE_LAST_NAME||','||DEPT_ID FROM EMPLOYEE;

SPOOL OFF
EXIT;
EOF
