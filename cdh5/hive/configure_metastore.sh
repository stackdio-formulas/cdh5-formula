{% set nn_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.namenode', 'grains.items', 'compound').values()[0]['fqdn'] %}
#!/bin/bash -e

# configure mysql
/usr/bin/mysql_secure_installation <<EOF

n
y
y
y
y
EOF


# create the metastore database
SETUPSQL="/tmp/hive_setup.sql"
cat >$SETUPSQL <<EOF
CREATE DATABASE metastore;
USE metastore;
SOURCE {{pillar.cdh5.hive.home}}/scripts/metastore/upgrade/mysql/hive-schema-0.12.0.mysql.sql;
CREATE USER '{{pillar.cdh5.hive.user}}'@'{{ nn_host }}' IDENTIFIED BY '{{pillar.cdh5.hive.metastore_password}}';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '{{pillar.cdh5.hive.user}}'@'{{ nn_host }}';
GRANT SELECT,INSERT,UPDATE,DELETE,LOCK TABLES,EXECUTE ON metastore.* TO '{{pillar.cdh5.hive.user}}'@'{{ nn_host }}';
FLUSH PRIVILEGES;
EOF

mysql -u root < $SETUPSQL

# cleanup
rm -f $SETUPSQL


