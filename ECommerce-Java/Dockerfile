FROM centos:centos6

# Install Oracle JDK
ADD jdk-linux-x64.rpm /
RUN rpm -Uvh /jdk-linux-x64.rpm
RUN yum -y install ntp
RUN yum -y install unzip
RUN yum -y install tar

RUN rm jdk-linux-x64.rpm
ENV JAVA_HOME /usr/java/default
ENV APPDYNAMICS_SIM_ENABLED true
ENV PATH $PATH:$JAVA_HOME/bin
