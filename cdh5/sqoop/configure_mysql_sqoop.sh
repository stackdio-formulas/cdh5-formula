#!/bin/bash -e

# create the metastore database
SETUPSQL="/tmp/sqoop_setup.sql"
cat >$SETUPSQL <<EOF
CREATE USER '{{ pillar.cdh5.sqoop.user }}'@'%{{ grains.namespace }}%' IDENTIFIED BY '{{ pillar.cdh5.sqoop.db_password }}';
GRANT ALL PRIVILEGES ON *.* TO '{{ pillar.cdh5.sqoop.user }}'@'%{{ grains.namespace }}%';
FLUSH PRIVILEGES;
EOF

mysql -u root < $SETUPSQL

# cleanup
rm -f $SETUPSQL


