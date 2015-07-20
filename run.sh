# This script is provided for illustration purposes only.
#
# To build the ECommerce demo application, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics AppServer Agent, Machine Agent and Database Monitoring Agent for your Controller installation
#    (https://download.appdynamics.com)
#
# To run the ECommerce demo application, you will also need to:
# 1. Build and run the ECommerce-Oracle docker container
#    The Dockerfile is available here (https://github.com/Appdynamics/ECommerce-Docker/tree/master/ECommerce-Oracle) 
#    The container requires you to downlaod an appropriate version of the Oracle Database Express Edition 11g Release 2
#    (http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html)
# 2. Download and run the official Docker mysql container
#    (https://registry.hub.docker.com/_/mysql/)

#!/bin/sh

# Docker container version
if [ -z "$1" ]; then
        export VERSION="latest";
else
        export VERSION=$1;
fi
echo "Using version: $VERSION"

# Default application name
if [ -z "$2" ]; then
        export APP_NAME="ECommerce";
else
        export APP_NAME=$2;
fi
echo "Application Name: $APP_NAME"

source env.sh

echo -n "db: "; docker run --name db -e MYSQL_ROOT_PASSWORD=singcontroller -p 3306:3306 -d mysql
sleep 30

echo -n "ws: "; docker run --name ws -h ${APP_NAME}-ws -e create_schema=true -e ws=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WS_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=Inventory-Services \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} --link db:db \
	-d appdynamics/ecommerce-tomcat:$VERSION

echo -n "web: "; docker run --name web -h ${APP_NAME}-web -e JVM_ROUTE=route1 -e web=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB1_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=ECommerce-Services \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link db:db --link ws:ws -d appdynamics/ecommerce-tomcat:$VERSION
sleep 30

echo -n "web1: "; docker run --name web1 -h ${APP_NAME}-web1 -e JVM_ROUTE=route2 -e web=true \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e NODE_NAME=${APP_NAME}_WEB2_NODE -e APP_NAME=$APP_NAME -e TIER_NAME=ECommerce-Services \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link db:db --link ws:ws -d appdynamics/ecommerce-tomcat:$VERSION
sleep 30

echo -n "lbr: "; docker run --name=lbr -h ${APP_NAME}-lbr \
	-e CONTROLLER=${CONTR_HOST} -e APPD_PORT=${CONTR_PORT} \
	-e APP_NAME=${APP_NAME} -e TIER_NAME=Web-Tier-Services -e NODE_NAME=${APP_NAME}-Apache \
	-e ACCOUNT_NAME=${ACCOUNT_NAME} -e ACCESS_KEY=${ACCESS_KEY} -e EVENT_ENDPOINT=${EVENT_ENDPOINT} \
	-e SIM_HIERARCHY_1=${SIM_HIERARCHY_1} -e SIM_HIERARCHY_2=${SIM_HIERARCHY_2} \
	--link web:web --link web1:web1 -p 80:80 -d appdynamics/ecommerce-lbr:$VERSION
sleep 30

echo -n "load-gen: "; docker run --name=load-gen --link lbr:lbr -d appdynamics/ecommerce-load
echo -n "angular: "; docker run --name angular -h ${APP_NAME}-angular \
	--link lbr:lbr -p 8080:8080 -d appdynamics/ecommerce-angular:$VERSION
