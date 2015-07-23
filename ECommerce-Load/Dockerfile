FROM appdynamics/ecommerce-java:oracle-java7

RUN yum -y install firefox
RUN yum -y install git
RUN yum -y install Xvfb

# Gradle
RUN curl -O http://downloads.gradle.org/distributions/gradle-2.5-bin.zip
RUN unzip gradle-2.5-bin.zip -d /opt/
RUN rm gradle-2.5-bin.zip
ENV GRADLE_HOME /opt/gradle-2.5
ENV PATH $PATH:$GRADLE_HOME/bin
ENV TERM dumb

RUN git clone https://github.com/Appdynamics/ECommerce-Load-NPM.git 
ENV LOAD_GEN_HOME /ECommerce-Load-NPM
RUN cd /ECommerce-Load-NPM; gradle distZip
RUN unzip ECommerce-Load-NPM/build/distributions/load-generator.zip -d /
RUN chmod +x $LOAD_GEN_HOME/bin/*
ADD env.sh /
ADD startup.sh /	
CMD ["/bin/bash","/startup.sh"]
