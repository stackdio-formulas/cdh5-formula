
# 
# Install the HBase master package
#

include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.hbase.regionserver.hostnames
  - cdh5.zookeeper
  - cdh5.hbase.conf
{% if salt['pillar.get']('cdh5:hbase:start_service', True) %}
  - cdh5.hbase.master.service
{% endif %}

extend:
  /etc/hbase/conf/hbase-site.xml:
    file:
      - require:
        - pkg: hbase-master
  /etc/hbase/conf/hbase-env.sh:
    file:
      - require:
        - pkg: hbase-master
  {{ pillar.cdh5.hbase.tmp_dir }}:
    file:
      - require:
        - pkg: hbase-master
  {{ pillar.cdh5.hbase.log_dir }}:
    file:
      - require:
        - pkg: hbase-master

hbase-master:
  pkg:
    - installed 
    - pkgs:
      - hbase-master
      - hbase-thrift
    - require:
      - module: cdh5_refresh_db
