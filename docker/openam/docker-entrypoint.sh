#!/usr/bin/env sh
#
# Copyright (c) 2016-2017 ForgeRock AS
#

########################
###### FUNCTIONS #######
########################

tomcat_pid() {
        echo `ps -fe | grep "$CATALINA_HOME" | grep -v grep | tr -s " "|cut -d" " -f2`
}

tomcat_stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "\e[00;31mStopping Tomcat\e[00m"
    #/bin/su -p -s /bin/sh tomcat
        sh $CATALINA_HOME/bin/shutdown.sh

    let kwait=$SHUTDOWN_WAIT
    count=0;
    echo -n -e "\n\e[00;31mwaiting for tomcat to stop\e[00m";
    until [ `ps | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\e[00;31m.\e[00m";
      sleep 1
      let count=$count+1;
    done

    if [ $count -gt $kwait ]; then
      echo -n -e "\n\e[00;31mkilling processes which didn't stop after $SHUTDOWN_WAIT seconds\e[00m"
      kill -9 $pid
    fi
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi
  echo -n -e "\e[00;31mDone\n\e[00m";
  return 0
}


tomcat_start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo -e "\e[00;31mTomcat is already running (pid: $pid)\e[00m"
  else
    # Start tomcat
    echo -e "\e[00;32mStarting tomcat\e[00m"
    #ulimit -n 100000
    #umask 007
    #/bin/su -p -s /bin/sh tomcat
    sh $CATALINA_HOME/bin/startup.sh
    #sh $CATALINA_HOME/bin/catalina.sh run
    echo -n -e "\n\e[00;32mwaiting for tomcat to start\e[00m";
    HTTP_PORT_STRING=`grep "Connector.*HTTP" $CATALINA_HOME/conf/server.xml | cut -d$'=' -f2 | cut -d$' ' -f1`
    HTTP_PORT=`echo ${HTTP_PORT_STRING//\"}`
    #until [ `netstat -ltn | grep -c 8005` = '1' ]
    until [ `curl -m 2 http://localhost:$HTTP_PORT/am/isAlive.jsp 2>/dev/null | grep -c html` != '0' ]
    do
        echo -n -e "\e[00;32m.\e[00m";
        sleep 1
    done
  fi
  return 0
}


function wait_for_openam
{
   response="000"
        while true
        do
        echo "Waiting for OpenAM server at ${CONFIG_URL}"
                response=$(curl --write-out %{http_code} --silent --output /dev/null ${CONFIG_URL} )
        echo "Got Response code $response"
        if [ ${response} == "302" ]; then
            break
        fi
        echo "response code ${response}. Will continue to wait..."
        sleep 5
    done
}



run() {
   if [ -x "${PRECONFIG_AM}" ]; then
        echo "Executing AM pre config script"
        sh "${PRECONFIG_AM}"
   else
        echo "No AM customization script found, so no customizations will be performed"
   fi

   cd "${CATALINA_HOME}"
   mv webapps/am webapps${URL}
   #exec tini -v -- "${CATALINA_HOME}/bin/catalina.sh" run
   ${CATALINA_HOME}/bin/startup.sh
   wait_for_openam
   # some time a 302 comes before 200's
   wait_for_openam
   echo "OpenAM web app is setup and alive!"
   echo "Proceeding with post configuration"
   $CONFIG_PATH/bin/post_config.sh
}


########################
###### MAIN ############
########################
DIR=`pwd`

command=$1

# Optional AM web app customization script that can be run before Tomcat starts.
PRECONFIG_AM="${PRECONFIG_AM:-$CONFIG_PATH/bin/pre_config.sh}"
export OPENAM_HOME=${OPENAM_HOME:-/home/forgerock/openam}

export OPENAM_SERVERNAME=`hostname -f`
export SHUTDOWN_WAIT=20
export SHUTDOWN_PORT=8005
export OPENAM_SERVER_URL="http://$OPENAM_SERVERNAME:8080${SERVER_URI}"
IS_ALIVE_URL="$OPENAM_SERVER_URL/isAlive.jsp"
CONFIG_URL="${OPENAM_SERVER_URL}/config/options.htm"

run

while :
do
    sleep 10000
done

