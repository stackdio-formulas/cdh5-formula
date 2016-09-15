
# 
# Start impala processes
#

impala-server:
  service:
    - running
    - require:
      - pkg: impala-server-install
      - file: /etc/default/impala
      - file: /etc/default/bigtop-utils
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      {% if 'cdh5.hbase.master' in grains['roles'] or 'cdh5.hbase.regionserver' in grains['roles'] %}
      - file: /etc/impala/conf/hbase-site.xml
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_impala_keytabs
      {% endif %}
