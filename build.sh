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
 
#! /bin/bash

cleanUp() {
  rm -f cookies.txt index.html* AppServerAgent.zip
  rm -rf ECommerce-Java-NPM

  (cd ECommerce-Java && rm -f jdk-linux-x64.rpm)
  (cd ECommerce-Tomcat && rm -rf AppServerAgent.zip ECommerce-Java-NPM)
  (cd ECommerce-OrderProcessor && rm -rf AppServerAgent.zip ECommerce-Java-NPM)
  (cd ECommerce-PaymentGateway && rm -rf AppServerAgent.zip ECommerce-Java-NPM)
  (cd ECommerce-Load && rm -rf ECommerce-Load)
  (cd ECommerce-Angular && rm -rf ECommerce-Angular)

  # Remove dangling images left-over from build
  if [[ `docker images -q --filter "dangling=true"` ]]
  then
    echo
    echo "Deleting intermediate containers..."
    docker images -q --filter "dangling=true" | xargs docker rmi;
  fi
}
trap cleanUp EXIT

promptForAgents() {
  read -e -p "Enter path to App Server Agent: " APP_SERVER_AGENT
  read -e -p "Enter path to Oracle JDK7: " ORACLE_JDK7
}

downloadAgents() {
  echo "Downloading latest agents from download.appdynamics.com"
  echo "Please supply your AppDynamics Portal login/password"

  read -e -p "Email/UserName: " USER_NAME

  stty -echo
  read -e -p "Password: " PASSWORD
  stty echo
  echo

  if [ ! -z "$USER_NAME" ] && [ ! -z "$PASSWORD" ];
    then
      wget --quiet --save-cookies cookies.txt  --post-data "username=$USER_NAME&password=$PASSWORD" --no-check-certificate https://login.appdynamics.com/sso/login/
      SSO_SESSIONID=`grep "sso-sessionid" cookies.txt`
      if [ ! "$SSO_SESSIONID" ]; then
        echo "Incorrect Login/Password"
      exit
    fi

    echo "Downloading AppDynamics App Server Agent..."
    wget --quiet --load-cookies cookies.txt https://download.appdynamics.com/onpremise/public/latest/AppServerAgent.zip -O AppServerAgent.zip
    if [ $? -ne 0 ]; then
      exit
    fi
    APP_SERVER_AGENT=AppServerAgent.zip
  fi
}

# Usage information
if [[ $1 == *--help* ]]
then
  echo "Specify agent locations: build.sh 
          -a <Path to App Server Agent> 
          -j <Path to Oracle JDK7>"
  echo "Prompt for agent locations: build.sh"
  echo "Download latest App Server Agent: build.sh --download"
  exit
fi

# Prompt for location of App Server, Machine and Database Agents
if  [ $# -eq 0 ]
then   
  promptForAgents

elif [ $1 == "--download" ]
then
  downloadAgents

else
  # Allow user to specify locations of App Server, Machine and Database Agents
  while getopts "a:j:" opt; do
    case $opt in
      a)
        APP_SERVER_AGENT=$OPTARG
        if [ ! -e ${APP_SERVER_AGENT} ]; then
          echo "Not found: ${APP_SERVER_AGENT}"; exit
        fi
        ;;
      j)
        ORACLE_JDK7=$OPTARG
        if [ ! -e ${ORACLE_JDK7} ]; then
          echo "Not found: ${ORACLE_JDK7}"; exit
        fi
        ;; 
      \?)
        echo "Invalid option: -$OPTARG"
        ;;
    esac
  done
fi

if [ -z ${APP_SERVER_AGENT} ]; then
    echo "Error: App Server Agent is required"; exit
fi

# Download Oracle JDK7 and build ecommerce-java base image
echo; echo "Building ECommerce-Java base image..."

if [ -z ${ORACLE_JDK7} ]
then
    echo "Downloading Oracle Java 7 JDK"
    (cd ECommerce-Java; curl -j -k -L -H "Cookie:oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u71-b13/jdk-7u71-linux-x64.rpm -o jdk-linux-x64.rpm)
else
    echo "Using JDK: ${ORACLE_JDK7}"
    cp ${ORACLE_JDK7} ECommerce-Java/jdk-linux-x64.rpm
fi

echo "Building ECommerce-Java..."
(cd ECommerce-Java; docker build -t appdynamics/ecommerce-npm-java .)
echo

cp ${APP_SERVER_AGENT} ECommerce-Tomcat/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ECommerce-OrderProcessor/AppServerAgent.zip
cp ${APP_SERVER_AGENT} ECommerce-PaymentGateway/AppServerAgent.zip
echo "Copied Agents for ECommerce-Tomcat"

git clone https://github.com/Appdynamics/ECommerce-Java-NPM.git
cp -r ECommerce-Java-NPM ECommerce-Tomcat/ECommerce-Java
cp -r ECommerce-Java-NPM ECommerce-OrderProcessor/ECommerce-Java-NPM
cp -r ECommerce-Java-NPM ECommerce-PaymentGateway/ECommerce-Java-NPM

# Build Tomcat containers
echo; echo "Building ECommerce-Tomcat..." 
(cd ECommerce-Tomcat && docker build -t appdynamics/ecommerce-npm-tomcat .)

# Build LoadGen container
echo; echo "Building ECommerce-Load..."
(cd ECommerce-Load && git clone https://github.com/Appdynamics/ECommerce-Load.git)
(cd ECommerce-Load && docker build -t appdynamics/ecommerce-npm-load .)

# Build Angular container
echo; echo "Building ECommerce-Angular..."
(cd ECommerce-Angular && git clone https://github.com/Appdynamics/ECommerce-Angular.git)
(cd ECommerce-Angular && docker build -t appdynamics/ecommerce-npm-angular .)

# Build OrderProcessor container
echo; echo "Building ECommerce-OrderProcessor..." 
(cd ECommerce-OrderProcessor && docker build -t appdynamics/ecommerce-npm-order-processor .)

# Build PaymentGateway container
echo; echo "Building ECommerce-PaymentGateway..." 
(cd ECommerce-PaymentGateway && docker build -t appdynamics/ecommerce-npm-payment-gateway .)
