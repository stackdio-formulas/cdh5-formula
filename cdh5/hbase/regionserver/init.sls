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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.hbase.security
{% endif %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
extend:
  load_admin_keytab:
    module:
      - require:
        - file: krb5_conf_file
        - file: /etc/hbase/conf/hbase-site.xml
        - file: /etc/hbase/conf/hbase-env.sh
        - pkg: hbase-regionserver
{% endif %}

hbase-regionserver:
  pkg:
    - installed 
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
