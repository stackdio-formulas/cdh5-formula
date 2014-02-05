/etc/hbase/conf/hbase-site.xml:
  file:
    - managed
    - source: salt://cdh5/etc/hbase/conf/hbase-site.xml
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/etc/hbase/conf/hbase-env.sh:
  file:
    - managed
    - source: salt://cdh5/etc/hbase/conf/hbase-env.sh
    - user: root
    - group: root
    - mode: 644
    - template: jinja

{{ pillar.cdh5.hbase.tmp_dir }}:
  file.directory:
    - user: hbase
    - group: hbase
    - dir_mode: 755
    - makedirs: True

{{ pillar.cdh5.hbase.log_dir }}:
  file.directory:
    - user: hbase
    - group: hbase
    - dir_mode: 755
    - makedirs: True

