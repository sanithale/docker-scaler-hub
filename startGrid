#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin
source /opt/bin/functions.sh

#check required params
#[ -z ${AWS_ACCESS_KEY} ] && echo "AWS_ACCESS_KEY MUST BE SET!" >> ./Dockerfile && exit 1
#[ -z ${AWS_SECRET_KEY} ] && echo "AWS_SECRET_KEY MUST BE SET!" >> ./Dockerfile && exit 1

export GEOMETRY="$SCREEN_WIDTH""x""$SCREEN_HEIGHT""x""$SCREEN_DEPTH"
export EC2_PRIVATE_IP_ID="`wget --tries=1 -q -O - http://169.254.169.254/latest/meta-data/local-ipv4`"

if [ ! -z "$SE_OPTS" ]; then
  echo "appending selenium options: ${SE_OPTS}"
fi

function shutdown {
    echo "shutting down hub.."
    kill -s SIGTERM $NODE_PID
    wait $NODE_PID
    echo "shutdown complete"
}

sed -i "s/<AWS_ACCESS_KEY>/${AWS_ACCESS_KEY}/g" /opt/selenium/selenium_grid_extras_config.json
sed -i "s/<AWS_SECRET_KEY>/${AWS_SECRET_KEY}/g" /opt/selenium/selenium_grid_extras_config.json
if [ ! -z "$IP_ADDRESS" ]; then
        sed -i "s/<IP_ADDRESS>/${IP_ADDRESS}/g" /opt/selenium/selenium_grid_extras_config.json
        sed -i "s/<IP_ADDRESS>/${IP_ADDRESS}/g" /opt/selenium/hub.json
else
        sed -i "s/<IP_ADDRESS>/${EC2_PRIVATE_IP_ID}/g" /opt/selenium/selenium_grid_extras_config.json
        sed -i "s/<IP_ADDRESS>/${EC2_PRIVATE_IP_ID}/g" /opt/selenium/hub.json
fi

SERVERNUM=$(get_server_num)

rm -f /tmp/.X*lock

#xvfb-run -n $SERVERNUM --server-args="$DISPLAY -screen 0 $GEOMETRY -ac +extension RANDR" \
#  java -jar /opt/selenium/selenium-grid-extras.jar &
#NODE_PID=$!

xvfb-run -n $SERVERNUM --server-args="$DISPLAY -screen 0 $GEOMETRY -ac +extension RANDR" \
    java -DipAddress="${EC2_PRIVATE_IP_ID}" \
    -DPOOL_MAX=1024 \
    -DtotalNodeCount=100 \
    -DpropertyFileLocation=/opt/selenium/aws.properties \
    -cp /opt/selenium/automation-grid.jar org.openqa.grid.selenium.GridLauncherV3 -role hub \
    -hubConfig /opt/selenium/hub.json \
    -jettyMaxThreads 1024 \
    -servlets "com.rmn.qa.servlet.AutomationTestRunServlet","com.rmn.qa.servlet.StatusServlet" &
NODE_PID=$!

trap shutdown SIGTERM SIGINT
