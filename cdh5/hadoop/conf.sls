/etc/hadoop/conf:
  file:
    - recurse
    - source: salt://cdh5/etc/hadoop/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644

/etc/hadoop/conf/log4j.properties:
  file:
    - replace
    - pattern: 'maxbackupindex=20'
    - repl: 'maxbackupindex={{ pillar.cdh5.max_log_index }}'
    - require:
      {% if 'cdh5.hadoop.namenode' in grains['roles'] %}
      - pkg: hadoop-hdfs-namenode
      {% endif %}
      {% if 'cdh5.hadoop.datanode' in grains['roles'] %}
      - pkg: hadoop-hdfs-datanode
      {% endif %}

