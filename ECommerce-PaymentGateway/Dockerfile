FROM appdynamics/ecommerce-java:oracle-java7

# Install Gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.1-bin.zip
RUN unzip gradle-2.1-bin.zip -d /opt/
RUN rm gradle-2.1-bin.zip
ENV GRADLE_HOME /opt/gradle-2.1
ENV PATH $PATH:$GRADLE_HOME/bin

# Copy ECommerce-Java project from build dir
ADD ECommerce-Java-NPM /ECommerce-Java-NPM

# Gradle build
RUN cd /ECommerce-Java-NPM/Ecommerce-CCPaymentGateway; gradle war;

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

# App Server Agent Install
ADD AppServerAgent.zip /
RUN unzip -q /AppServerAgent.zip -d ${CATALINA_HOME}/appagent;rm AppServerAgent.zip

# Startup scripts
ADD startup.sh /
RUN version=`find ${CATALINA_HOME}/appagent -type d -name "ver*" | sed "s:^${CATALINA_HOME}/appagent/::"`; \
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
