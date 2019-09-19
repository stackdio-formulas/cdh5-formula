# 
# Install the HBase regionserver package
#

hbase-regionserver-svc:
  service.running:
    - name: hbase-regionserver
    - require: 
      - pkg: hbase-regionserver
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: {{ pillar.cdh5.hbase.log_dir }}
      - cmd: hbase-regionserver-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-hbase-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hbase_keytab
      {% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
