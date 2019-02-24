#!/usr/bin/env bash
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

RANGER_SQL_CONNECTOR_JAR=${RANGER_SQL_CONNECTOR_JAR:-"/usr/local/share/java/mysql-connector-java.jar"}
RANGER_ADMIN_DB_ROOT_USER=${RANGER_ADMIN_DB_ROOT_USER:-"rangerdba"}
RANGER_ADMIN_DB_ROOT_PASSWORD=${RANGER_ADMIN_DB_ROOT_PASSWORD:-"rangerdba"}
RANGER_ADMIN_DB_HOST=${RANGER_ADMIN_DB_HOST:-"mariadb"}
RANGER_ADMIN_DB_NAME=${RANGER_ADMIN_DB_NAME:-"rangerdb"}
RANGER_ADMIN_DB_USER=${RANGER_ADMIN_DB_USER:-"admin"}
RANGER_ADMIN_DB_PASSWORD=${RANGER_ADMIN_DB_PASSWORD:-"admin1234"}

SOLR_URL=${SOLR_URL:-"http://solr:8983/solr"}
SOLR_COLLECTION=${SOLR_COLLECTION:-"ranger_audits"}
HOSTNAME=${HOSTNAME:-"localhost"}

XAPOLICYMGR_EWS_DIR=$RANGER_ADMIN_PATH/ews
RANGER_JAAS_LIB_DIR="${XAPOLICYMGR_EWS_DIR}/ranger_jaas"
RANGER_JAAS_CONF_DIR="${XAPOLICYMGR_EWS_DIR}/webapp/WEB-INF/classes/conf/ranger_jaas"
RANGER_ADMIN_HOSTNAME="localhost"
RANGER_ADMIN_CONF="/etc/conf/ranger-admin"
RANGER_ADMIN_SITE_CONFIG="${XAPOLICYMGR_EWS_DIR}/webapp/WEB-INF/classes/conf/ranger-admin-site.xml"
SERVER_NAME="rangeradmin"
RANGER_ADMIN_LOG_DIR="/var/log/ranger"

function setup() {
  local file_to_update=${1:?"usage: <filename_to_update>"}
  sed -i "s|{RANGER_SQL_CONNECTOR_JAR}|$RANGER_SQL_CONNECTOR_JAR|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_ROOT_USER}|$RANGER_ADMIN_DB_ROOT_USER|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_ROOT_PASSWORD}|$RANGER_ADMIN_DB_ROOT_PASSWORD|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_HOST}|$RANGER_ADMIN_DB_HOST|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_NAME}|$RANGER_ADMIN_DB_NAME|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_USER}|$RANGER_ADMIN_DB_USER|g" $file_to_update
  sed -i "s|{RANGER_ADMIN_DB_PASSWORD}|$RANGER_ADMIN_DB_PASSWORD|g" $file_to_update
  sed -i "s|{SOLR_URL}|$SOLR_URL|g" $file_to_update
  sed -i "s|{SOLR_COLLECTION}|$SOLR_COLLECTION|g" $file_to_update

  sed -i "s|{RANGER_ADMIN_HOSTNAME}|$RANGER_ADMIN_HOSTNAME|g" $RANGER_ADMIN_SITE_CONFIG

  /usr/local/ranger-admin/setup.sh
}

function start() {
  setup $RANGER_ADMIN_PATH/bin/install.properties

  java -Dproc_rangeradmin ${JAVA_OPTS} -Duser=${USER} -Dhostname=$(hostname -f) \
    -Dlog4j.configuration="file:${RANGER_ADMIN_CONF}/log4j.xml" -Dranger.service.host=${RANGER_ADMIN_HOSTNAME} \
    -Dxa.webapp.dir="${XAPOLICYMGR_EWS_DIR}/webapp" \
    ${DB_SSL_PARAM} -Dservername=${SERVER_NAME} -Dlogdir=${RANGER_ADMIN_LOG_DIR} -Dcatalina.base=${XAPOLICYMGR_EWS_DIR} \
    -cp "${XAPOLICYMGR_EWS_DIR}/webapp/WEB-INF/classes/conf:${XAPOLICYMGR_EWS_DIR}/lib/*:${RANGER_JAAS_LIB_DIR}/*:${RANGER_JAAS_CONF_DIR}:${JAVA_HOME}/lib/*:${RANGER_HADOOP_CONF_DIR}/*:$CLASSPATH:$RANGER_ADMIN_CONF" \
    org.apache.ranger.server.tomcat.EmbeddedServer
}

if [[ -f "$RANGER_ADMIN_INIT_FILE" ]]; then
  $RANGER_ADMIN_INIT_FILE
fi

start ${@}
