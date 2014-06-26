
# 
# Install the HBase regionserver package
#

hbase-regionserver-svc:
  service:
    - running
    - name: hbase-regionserver
    - require: 
      - pkg: hbase-regionserver
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh


