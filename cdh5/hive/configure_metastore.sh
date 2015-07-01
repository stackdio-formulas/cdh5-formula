#!/bin/bash -e

# configure mysql
/usr/bin/mysql_secure_installation <<EOF

n
y
y
y
y
EOF

HIVE_VERSION=`hive --version | head -n1 | cut -d ' ' -f2 | cut -d '-' -f1 | cut -d '.' -f1-2`

# create the metastore database
SETUPSQL="/tmp/hive_setup.sql"
cat >${SETUPSQL} <<EOF
CREATE DATABASE metastore;
USE metastore;
SOURCE {{pillar.cdh5.hive.home}}/scripts/metastore/upgrade/mysql/hive-schema-${HIVE_VERSION}.0.mysql.sql;
CREATE USER '{{pillar.cdh5.hive.user}}'@'localhost' IDENTIFIED BY '{{pillar.cdh5.hive.metastore_password}}';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '{{pillar.cdh5.hive.user}}'@'localhost';
GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO '{{pillar.cdh5.hive.user}}'@'localhost';
FLUSH PRIVILEGES;
EOF

# The script sources another scrip in that directory, so if we aren't in this directory,
# everything breaks
cd {{pillar.cdh5.hive.home}}/scripts/metastore/upgrade/mysql

mysql -u root < ${SETUPSQL}

# cleanup
rm -f ${SETUPSQL}


