# 
# Install the HBase client package
#
include:
  - cdh5.repo
  - cdh5.hbase.conf
  - cdh5.landing_page
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hbase.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hbase.security
  {% endif %}

hbase:
  pkg:
    - installed
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
