# 
# Install the HBase master package
#
include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.hbase.conf
{% if salt['pillar.get']('cdh5:hbase:manage_zk', True) %}
  - cdh5.zookeeper
{% endif %}
{% if salt['pillar.get']('cdh5:hbase:start_service', True) %}
  - cdh5.hbase.master.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.hbase.security
{% endif %}

hbase-master:
  pkg:
    - installed 
    - pkgs:
      - hbase-master
      - hbase-thrift
    - require:
      - module: cdh5_refresh_db
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: krb5_conf_file
{% endif %}
    - require_in:
      - file: {{ pillar.cdh5.hbase.log_dir }}
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: /etc/hbase/conf/hbase-env.sh
      - file: /etc/hbase/conf/hbase-site.xml
