
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

hive-metastore:
  service:
    - running
    - require: 
      - pkg: hive
      - cmd: configure_metastore
      - service: mysql-svc
      - file: /usr/lib/hive/lib/mysql-connector-java.jar
      - file: /etc/hive/conf/hive-site.xml

hive-server2:
  service:
    - running
    - require: 
      - service: hive-metastore


