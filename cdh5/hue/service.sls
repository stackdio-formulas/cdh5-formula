{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}
#
# Start the Hue service
#

/etc/hue/conf/hue.ini:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hue/hue.ini
    - mode: 755
    - require:
      - pkg: hue

{% if salt['pillar.get']('cdh5:security:enable', False) %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hbase_keytabs
{% endif %}

hue_dir:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs dfs -mkdir -p /user/hue && hdfs dfs -chown hue:hue /user/hue
    - unless: 'hdfs dfs -test -d /user/hue'
    - require:
      - pkg: hadoop-client
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
      
{% if kms %}
create_hue_key:
  cmd:
    - run
    - user: root
    - name: 'hadoop key create hue'
    - unless: 'hadoop key list | grep hue'
    {% if salt['pillar.get']('cdh5:security:enable', False) %}
    - require:
      - cmd: hdfs_kinit
    {% endif %}

create_hue_zone:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName hue -path /user/hue'
    - unless: 'hdfs crypto -listZones | grep /user/hue'
    - require:
      - cmd: create_hue_key
      - cmd: hue_dir
    - require_in:
      - service: hue-svc
{% endif %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
/etc/init.d/hue:
  file:
    - replace
    - pattern: 'USER=hue'
    - repl: 'USER=hue\nexport KRB5_CONFIG={{ pillar.krb5.conf_file }}'
    - unless: cat /etc/init.d/hue | grep KRB5_CONFIG
    - require:
      - pkg: hue
    - require_in:
      - service: hue-svc
    - watch_in:
      - service: hue-svc
{% endif %}

hue-svc:
  service:
    - running
    - name: hue
    - require:
      - pkg: hue
      - file: /mnt/tmp/hadoop
      - file: /etc/hue/conf/hue.ini
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hue_keytabs 
{% endif %}
    - watch:
      - file: /etc/hue/conf/hue.ini
