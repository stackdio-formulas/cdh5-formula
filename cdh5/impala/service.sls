
# 
# Start impala processes
#

{% if 'cdh5.hadoop.namenode' in grains['roles'] %}
impala-state-store:
  service:
    - running
    - require:
      - pkg: impala
      - file: /etc/default/impala
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      - file: /etc/impala/conf/hbase-site.xml

impala-catalog:
  service:
    - running
    - require:
      - pkg: impala
      - service: impala-state-store
      - file: /etc/default/impala
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      - file: /etc/impala/conf/hbase-site.xml
{% endif %}

impala-server:
  service:
    - running
    - require:
      - pkg: impala
      - file: /etc/default/impala
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      - file: /etc/impala/conf/hbase-site.xml

