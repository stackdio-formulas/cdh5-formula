{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: impala-server
{% endif %}

# 
# Start impala processes
#

impala-server:
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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_impala_keytabs
{% endif %}
