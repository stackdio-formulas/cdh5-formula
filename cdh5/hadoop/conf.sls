/etc/hadoop/conf:
  file:
    - recurse
    - source: salt://cdh5/etc/hadoop/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - exclude_pat: '.*.swp'

{% if 'cdh5.hadoop.namenode' in grains.roles or 'cdh5.hadoop.datanode' in grains.roles %}
/etc/hadoop/conf/container-executor.cfg:
  file:
    - managed
    - mode: 400
    - replace: false
    - user: root
    - group: yarn
    - require:
      - file: /etc/hadoop/conf
{% endif %}

/etc/hadoop/conf/log4j.properties:
  file:
    - replace
    - pattern: 'maxbackupindex=20'
    - repl: 'maxbackupindex={{ pillar.cdh5.max_log_index }}'
    - require:
      - file: /etc/hadoop/conf
