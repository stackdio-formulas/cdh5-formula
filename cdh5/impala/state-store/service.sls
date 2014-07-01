{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: impala-state-store
        - service: impala-catalog
{% endif %}

# 
# Start impala processes
#

impala-state-store:
  service:
    - running
    - require:
      - pkg: impala
      - file: /etc/default/impala
      - file: /etc/default/bigtop-utils
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
      - file: /etc/default/bigtop-utils
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      - file: /etc/impala/conf/hbase-site.xml

