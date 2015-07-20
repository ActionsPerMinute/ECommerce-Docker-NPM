#!/bin/sh

source /env.sh

cp ECommerce-NPM/build/libs/order.war /tomcat/webapps

# This script should not return or the container will exit
# The last command called should execute in the foreground

# Start App Server Agent
/start-appserver-agent.sh

