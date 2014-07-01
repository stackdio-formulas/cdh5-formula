
# 
# Install the HBase regionserver package
#

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: hbase-regionserver-svc
{% endif %}

hbase-regionserver-svc:
  service:
    - running
    - name: hbase-regionserver
    - require: 
      - pkg: hbase-regionserver
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: {{ pillar.cdh5.hbase.log_dir }}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh


