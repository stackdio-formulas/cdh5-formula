
# 
# Install the HBase regionserver package
#

include:
  - cdh5.repo
  - cdh5.landing_page
  - cdh5.hbase.conf
{% if salt['pillar.get']('cdh5:hbase:start_service', True) %}
  - cdh5.hbase.regionserver.service
{% endif %}

extend:
  /etc/hbase/conf/hbase-site.xml:
    file:
      - require:
        - pkg: hbase-regionserver
  /etc/hbase/conf/hbase-env.sh:
    file:
      - require:
        - pkg: hbase-regionserver
  {{ pillar.cdh5.hbase.tmp_dir }}:
    file:
      - require:
        - pkg: hbase-regionserver
  {{ pillar.cdh5.hbase.log_dir }}:
    file:
      - require:
        - pkg: hbase-regionserver

hbase-regionserver:
  pkg:
    - installed 
    - require:
      - module: cdh5_refresh_db
    
