
/etc/default/impala:
  file:
    - managed
    - source: salt://cdh5/impala/defaults
    - template: jinja
    - makedirs: true

/etc/default/bigtop-utils:
  file:
    - managed
    - source: salt://cdh5/impala/bigtop-utils
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

{% if 'cdh5.hbase.master' in grains['roles'] or 'cdh5.hbase.regionserver' in grains['roles'] %}
/etc/impala/conf/hbase-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hbase/conf/hbase-site.xml
{% endif %}