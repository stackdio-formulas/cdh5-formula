include:
  - cdh5.repo
{% if salt['pillar.get']('cdh5:impala:start_service', True) %}
  - cdh5.impala.service
{% endif %}

impala:
  pkg:
    - installed
    - pkgs:
      - impala
      - impala-catalog
      - impala-state-store
      - impala-server
      - impala-shell
    - require:
      - module: cdh5_refresh_db

/etc/default/impala:
  file:
    - managed
    - source: salt://cdh5/impala/defaults
    - template: jinja
    - makedirs: true

/etc/impala/conf/hive-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hive/hive-site.xml

/etc/impala/conf/core-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hadoop/conf/core-site.xml

/etc/impala/conf/hdfs-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hadoop/conf/hdfs-site.xml

/etc/impala/conf/hbase-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hbase/conf/hbase-site.xml



