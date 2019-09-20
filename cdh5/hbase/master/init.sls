# 
# Install the HBase master package
#
include:
  - cdh5.repo
  - cdh5.landing_page
  - cdh5.hadoop.client
  - cdh5.hbase.conf
  {% if salt['pillar.get']('cdh5:hbase:start_service', True) %}
  - cdh5.hbase.master.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hbase.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.hbase.security
  {% endif %}

hbase-master:
  pkg.installed:
    - pkgs:
      - hbase-master
      - hbase-thrift
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: {{ pillar.cdh5.hbase.log_dir }}
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: /etc/hbase/conf/hbase-env.sh
      - file: /etc/hbase/conf/hbase-site.xml

hbase-master-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hbase-master"
    - require:
      - pkg: hbase-master

hbase-thrift-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hbase-thrift"
    - require:
      - pkg: hbase-master
