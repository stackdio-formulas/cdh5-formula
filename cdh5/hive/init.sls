
# 
# Install the Hive package
#

include:
  - cdh5.repo
{% if salt['pillar.get']('cdh5:hive:start_service', True) %}
  - cdh5.hive.service
{% endif %}

hive:
  pkg:
    - installed
    - pkgs:
      - hive
      - hive-metastore
      - hive-server2
    - require:
      - pkg: mysql
      - module: cdh5_refresh_db

# @todo move this out to its own formula
mysql:
  pkg:
    - installed
    - pkgs:
      - mysql-server
      - mysql-connector-java

/usr/lib/hive/lib/mysql-connector-java.jar:
  file:
    - symlink
    - target: /usr/share/java/mysql-connector-java.jar
    - require: 
      - pkg: mysql

/etc/hive/conf/hive-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hive/hive-site.xml
