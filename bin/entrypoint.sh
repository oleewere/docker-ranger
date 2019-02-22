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

RANGER_SQL_CONNECTOR_JAR=${RANGER_SQL_CONNECTOR_JAR:-"localhost:9983"}
RANGER_ADMIN_DB_ROOT_USER=${RANGER_ADMIN_DB_ROOT_USER:-"rangerdba"}
RANGER_ADMIN_DB_ROOT_PASSWORD=${RANGER_ADMIN_DB_ROOT_PASSWORD:-"rangerdba"}
RANGER_ADMIN_DB_HOST=${RANGER_ADMIN_DB_HOST:-"mariadb"}
RANGER_ADMIN_DB_NAME=${RANGER_ADMIN_DB_NAME:-"rangerdb"}
RANGER_ADMIN_DB_USER=${RANGER_ADMIN_DB_USER:-"admin"}
RANGER_ADMIN_DB_PASSWORD=${RANGER_ADMIN_DB_PASSWORD:-"admin1234"}

SOLR_URL=${SOLR_URL:-"http://solr:8983/solr"}
SOLR_COLLECTION=${SOLR_COLLECTION:-"ranger_audits"}
HOSTNAME=${HOSTNAME:-"localhost"}

function setup() {
  echo "Setup..."
  export HOSTNAME=${HOSTNAME}
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
  cat /usr/local/ranger-admin/bin/install.properties
  /usr/local/ranger-admin/setup.sh
}

function start() {
  setup $RANGER_ADMIN_PATH/bin/install.properties
  /usr/local/ranger-admin/ews/ranger-admin-services.sh start
  ls -la /var/log/ranger
  cat $RANGER_ADMIN_PATH/ews/logs/catalina.out
  tail -f /var/log/ranger/ranger_admin.log
}

if [[ -f "$RANGER_ADMIN_INIT_FILE" ]]; then
  $RANGER_ADMIN_INIT_FILE
fi

start ${@}
