/etc/hive/conf/hive-site.xml:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hive/hive-site.xml
