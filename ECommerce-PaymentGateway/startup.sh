#!/bin/sh

source /env.sh

cp ECommerce-PaymentGateway/build/libs/ECommerce-CCPaymentGateway.war /tomcat/webapps

# This script should not return or the container will exit
# The last command called should execute in the foreground

# Start App Server Agent
/start-appserver-agent.sh

