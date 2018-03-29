#install python dependencies and rack script
{% if pillar.cdh5.spot_or_not_rack %}
/etc/hadoop/conf/set_rack.py:
  file:
    - managed
    - source: salt://cdh5/etc/hadoop/conf/set_rack.py
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/hadoop/conf


python_dep:
  pkg:
    - installed
    - pkgs:
      - python
      - python2-boto3
{% endif %}

/etc/hadoop/conf:
  file:
    - recurse
    - source: salt://cdh5/etc/hadoop/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    {% if pillar.cdh5.encryption.enable %}
    - exclude_pat: .*.swp
    {% else %}
    - exclude_pat: ssl-*.xml
    {% endif %}

/mnt/tmp/hadoop:
  file:
    - directory
    - user: root
    - group: root
    - mode: 777
    - makedirs: true

/tmp/hadoop:
  file:
    - symlink
    - target: /mnt/tmp/hadoop
    - user: root
    - group: root
    - mode: 777
    - require:
      - file: /mnt/tmp/hadoop

/etc/hadoop/conf/container-executor.cfg:
  file:
    - managed
    - mode: 400
    - replace: false
    - user: root
    - group: root
    - require:
      - file: /etc/hadoop/conf

/etc/hadoop/conf/log4j.properties:
  file:
    - replace
    - pattern: 'maxbackupindex=20'
    - repl: 'maxbackupindex={{ pillar.cdh5.max_log_index }}'
    - require:
      - file: /etc/hadoop/conf