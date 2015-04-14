#!/bin/bash

# This script mirrors /usr/lib/oozie/bin/oozie-setup.sh, but ONLY creates the sharelib.
# We need this in order to support a custom location for the krb5.conf file.

BASEDIR="/usr/lib/oozie"

source ${BASEDIR}/bin/oozie-sys.sh -silent

OOZIE_OPTS="-Doozie.home.dir=${OOZIE_HOME}";
OOZIE_OPTS="${OOZIE_OPTS} -Doozie.config.dir=${OOZIE_CONFIG}";
OOZIE_OPTS="${OOZIE_OPTS} -Doozie.log.dir=${OOZIE_LOG}";
OOZIE_OPTS="${OOZIE_OPTS} -Doozie.data.dir=${OOZIE_DATA}";
OOZIE_OPTS="${OOZIE_OPTS} -Dderby.stream.error.file=${OOZIE_LOG}/derby.log"
OOZIE_OPTS="${OOZIE_OPTS} -Djava.security.krb5.conf={{ pillar.krb5.conf_file }}"


OOZIECPPATH=""
OOZIECPPATH=${BASEDIR}/libtools/'*':${BASEDIR}/libext/'*'

if test -z ${JAVA_HOME}; then
  JAVA_BIN=java
else
  JAVA_BIN=${JAVA_HOME}/bin/java
fi

${JAVA_BIN} ${OOZIE_OPTS} -cp ${OOZIECPPATH} org.apache.oozie.tools.OozieSharelibCLI "create -fs hdfs://{{nn_host}}:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz"

exit $?