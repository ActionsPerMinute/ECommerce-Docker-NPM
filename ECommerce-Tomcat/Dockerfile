FROM appdynamics/ecommerce-npm-java:oracle-java7

# Install Git
RUN yum -y install git

# Install Gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.5-bin.zip
RUN unzip gradle-2.5-bin.zip -d /opt/
RUN rm gradle-2.5-bin.zip
ENV GRADLE_HOME /opt/gradle-2.5
ENV PATH $PATH:$GRADLE_HOME/bin

# Environment vars: Tomcat
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.14
ENV CATALINA_HOME /tomcat

# Environment settings for startup scripts
ADD env.sh /
RUN chmod +x /env.sh

# Install Tomcat
RUN curl -O -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz \
    && curl -O -k https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 \
    && md5sum apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 \
    && tar zxf apache-tomcat-*.tar.gz \
    && rm apache-tomcat-*.tar.gz* \
    && mv apache-tomcat-${TOMCAT_MINOR_VERSION} tomcat
RUN cd ${CATALINA_HOME}/bin;chmod +x *.sh

# Clone ECommerce-Java-NPM source code project
RUN git clone https://github.com/Appdynamics/ECommerce-Java-NPM.git

# Gradle build
RUN cd /ECommerce-Java-NPM; gradle war
RUN mkdir -p /webapps
RUN cp /ECommerce-Java-NPM/ECommerce-PaymentGateway/build/libs/paymentgateway.war /webapps/
RUN cp /ECommerce-Java-NPM/ECommerce-OrderProcessor/build/libs/order.war /webapps/
RUN cp /ECommerce-Java-NPM/ECommerce-Web/build/libs/appdynamicspilot.war /webapps/
RUN cp /ECommerce-Java-NPM/ECommerce-WS/build/libs/cart.war /webapps/

# Remove ECommerce-Java-NPM source code
#RUN rm -rf /ECommerce-Java-NPM

# App Server Agent Install
ADD AppServerAgent.zip /
RUN unzip -q /AppServerAgent.zip -d ${CATALINA_HOME}/appagent;rm AppServerAgent.zip

# Startup scripts
ADD startup.sh /
RUN version=`find ${CATALINA_HOME}/appagent -type d -name "ver*" | head -n 1 | sed "s:^${CATALINA_HOME}/appagent/::"`; \
    sed -e "s:_VERSION_STRING:$version:g" env.sh > env.sh.tmp && mv env.sh.tmp env.sh
ADD start-appserver-agent.sh /

RUN chmod +x /startup.sh
RUN chmod +x /start-appserver-agent.sh

WORKDIR /

# Note: This command should not return or the container will exit
CMD "/startup.sh"

EXPOSE 80
EXPOSE 8080
EXPOSE 8009
