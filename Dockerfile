FROM openjdk:8-jre
MAINTAINER oleewere@gmail.com

ENV RANGER_ADMIN_VERSION 2.0.0-SNAPSHOT
ENV RANGER_DOWNLOAD_URL https://github.com/oleewere/playground/releases/download/ranger/ranger-$RANGER_ADMIN_VERSION-admin.tar.gz
ENV MYSQL_JAVA_CONNECTOR_VERSION 5.1.38

RUN wget --no-check-certificate -O /root/ranger-$RANGER_ADMIN_VERSION-admin.tar.gz $RANGER_DOWNLOAD_URL
RUN wget --no-check-certificate -O /root/mysql-connector.tar.gz https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_JAVA_CONNECTOR_VERSION.tar.gz
RUN cd /usr/local && tar zxvf /root/ranger-$RANGER_ADMIN_VERSION-admin.tar.gz
RUN ln -s /usr/local/ranger-$RANGER_ADMIN_VERSION-admin /usr/local/ranger-admin
RUN mkdir /usr/local/share/mysql && \
  cd /root/ && tar zxvf /root/mysql-connector.tar.gz && \
  cp /root/mysql-connector-java-$MYSQL_JAVA_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_JAVA_CONNECTOR_VERSION-bin.jar /usr/local/share/mysql/mysql-connector-java.jar
ENV RANGER_SQL_CONNECTOR_JAR /usr/local/share/mysql/mysql-connector-java.jar

RUN apt-get update && apt-get install -y python procps
RUN ls -la /usr/local/ranger-$RANGER_ADMIN_VERSION-admin

ENV RANGER_ADMIN_PATH /usr/local/ranger-admin
ENV JAVA_HOME="/usr/java/default"
ENV RANGER_ADMIN_USER="rangeradmin"
ENV RANGER_ADMIN_GROUP="rangeradmin"
ENV RANGER_ADMIN_UID="6080"
ENV RANGER_ADMIN_GID="6080"

ADD bin/entrypoint.sh /entrypoint.sh
ADD bin/init.sh /init.sh
ADD conf/install.properties $RANGER_ADMIN_PATH/bin/install.properties

WORKDIR /usr/local/ranger-admin

RUN groupadd -r --gid $RANGER_ADMIN_GID $RANGER_ADMIN_GROUP && useradd -r --uid $RANGER_ADMIN_UID --gid $RANGER_ADMIN_GID $RANGER_ADMIN_USER
RUN mkdir -p /var/log/ranger && chown -R $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP /var/log/ranger
RUN mkdir -p /var/run/ranger && chown -R $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP /var/run/ranger
RUN mkdir -p $RANGER_ADMIN_PATH/ews/logs && chown -R $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP $RANGER_ADMIN_PATH/ews/logs
RUN mkdir -p $RANGER_ADMIN_PATH/ews/webapp/WEB-INF/classes/conf && chown -R $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP $RANGER_ADMIN_PATH/ews/webapp/WEB-INF/classes/conf
RUN find $RANGER_ADMIN_PATH -type d -exec chmod 755 {} +
RUN find $RANGER_ADMIN_PATH -type f -exec chmod 660 {} +
RUN chown $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP /usr/local/ranger-$RANGER_ADMIN_VERSION-admin
RUN chown $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP $RANGER_ADMIN_PATH
RUN chown -R $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP $RANGER_ADMIN_PATH/**
RUN chown $RANGER_ADMIN_USER:$RANGER_ADMIN_GROUP /usr/local/share/mysql/mysql-connector-java.jar

RUN chmod 755 /entrypoint.sh
RUN chmod 755 /init.sh

USER $RANGER_ADMIN_USER
CMD ["/entrypoint.sh"]
