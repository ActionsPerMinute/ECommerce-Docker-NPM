#!/bin/sh

source /env.sh

if [ "${create_schema}" == "true" ]; then
  cd /ECommerce-Java-NPM; gradle --info createDB 
fi

if [ -n "${web}" ]; then
  cp  /webapps/appdynamicspilot.war /tomcat/webapps;
fi

if [ -n "${ws}" ]; then
  cp /webapps/cart.war /tomcat/webapps;
fi

if [ -n "${payments}" ]; then
  cp /webapps/paymentgateway.war /tomcat/webapps/
fi

if [ -n "${orders}" ]; then
  cp /webapps/order.war /tomcat/webapps/
fi

# This script should not return or the container will exit
# The last command called should execute in the foreground

# Start App Server Agent
/start-appserver-agent.sh

