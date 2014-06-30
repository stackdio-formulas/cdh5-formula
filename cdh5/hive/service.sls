
# 
# Start the Hive service
#

include:
  - cdh5.repo

# @todo move this out to its own formula
mysql-svc:
  service:
    - running
    - name: mysqld
    - require:
      - pkg: mysql

configure_metastore:
  cmd:
    - script
    - template: jinja
    - source: salt://cdh5/hive/configure_metastore.sh
    - unless: echo "show databases" | mysql -u root | grep metastore
    - require: 
      - pkg: hive

create_warehouse_dir:
  cmd:
    - run
    - name: 'hdfs dfs -mkdir -p /user/{{pillar.cdh5.hive.user}}/warehouse'
    - user: hdfs
    - group: hdfs
    - require:
      - pkg: hive

warehouse_dir_owner:
  cmd:
    - run
    - name: 'hdfs dfs -chown -R {{pillar.cdh5.hive.user}}:{{pillar.cdh5.hive.user}} /user/{{pillar.cdh5.hive.user}}'
    - user: hdfs
    - group: hdfs
    - require:
      - cmd: create_warehouse_dir

warehouse_dir_permissions:
  cmd:
    - run
    - name: 'hdfs dfs -chmod 1777 /user/{{pillar.cdh5.hive.user}}/warehouse'
    - user: hdfs
    - group: hdfs
    - require:
      - cmd: warehouse_dir_owner

hive-metastore:
  service:
    - running
    - require: 
      - pkg: hive
      - cmd: configure_metastore
      - cmd: warehouse_dir_permissions
      - service: mysql-svc
      - file: /usr/lib/hive/lib/mysql-connector-java.jar
      - file: /etc/hive/conf/hive-site.xml
      - file: /mnt/tmp/

hive-server2:
  service:
    - running
    - require: 
      - service: hive-metastore

/mnt/tmp/:
  file:
    - directory
    - user: root
    - group: root
    - dir_mode: 777

