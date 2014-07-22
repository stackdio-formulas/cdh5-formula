#
# Install the ZooKeeper service
#
include:
  - cdh5.repo
{% if salt['pillar.get']('cdh5:zookeeper:start_service', True) %}
  - cdh5.zookeeper.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.zookeeper.security
{% endif %}

zookeeper:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db

zookeeper-server:
  pkg:
    - installed
    - require:
      - pkg: zookeeper

/etc/zookeeper/conf/log4j.properties:
  file:
    - replace
    - pattern: 'maxbackupindex=20'
    - repl: 'maxbackupindex={{ pillar.cdh5.max_log_index }}'
    - require:
      - pkg: zookeeper-server


