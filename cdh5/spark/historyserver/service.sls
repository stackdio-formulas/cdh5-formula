{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
# to require this state to be sure we have a krb ticket
{% if pillar.cdh5.security.enable %}
hdfs_kinit:
  cmd.run:
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require_in:
      - cmd: history-dir

hdfs_kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hdfs_kinit
      - cmd: history-dir
{% endif %}

history-dir:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p /user/spark/applicationHistory && hdfs dfs -chown -R spark:spark /user/spark && hdfs dfs -chmod 1777 /user/spark/applicationHistory'
    - require:
      - pkg: spark-history-server

{% if kms %}

{% if pillar.cdh5.security.enable %}
spark_kinit:
  cmd.run:
    - name: 'kinit -kt /etc/spark/conf/spark.keytab spark/{{ grains.fqdn }}'
    - user: spark
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_spark_keytabs
    - require_in:
      - cmd: create_spark_key
      - cmd: create_spark_zone

spark_kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: spark
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: spark_kinit
      - cmd: create_spark_key
      - cmd: create_spark_zone
{% endif %}

create_spark_key:
  cmd.run:
    - user: spark
    - name: 'hadoop key create spark-key'
    - unless: 'hadoop key list | grep spark-key'

create_spark_zone:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName spark-key -path /user/spark/applicationHistory'
    - unless: 'hdfs crypto -listZones | grep /user/spark/applicationHistory'
    - require:
      - cmd: create_spark_key
      - cmd: history-dir
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kinit
      {% endif %}
    - require_in:
      - service: spark-history-server-svc
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kdestroy
      {% endif %}
{% endif %}

/etc/spark/conf/spark-defaults.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-defaults.conf
    - template: jinja
    - require:
      - pkg: spark-history-server

/etc/spark/conf/spark-history-server.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-history-server.conf
    - template: jinja
    - require:
      - pkg: spark-history-server

/etc/default/spark:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/default/spark
    - template: jinja
    - require:
      - pkg: spark-history-server

/etc/spark/conf/spark-env.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://cdh5/etc/spark/spark-env.sh
    - template: jinja
    - require:
      - pkg: spark-history-server

/mnt/spark:
  file.directory:
    - user: spark
    - group: spark
    - require:
      - pkg: spark-history-server

/mnt/spark/logs:
  file.directory:
    - user: spark
    - group: spark
    - require:
      - pkg: spark-history-server
      - file: /mnt/spark

spark-history-server-svc:
  service.running:
    - name: spark-history-server
    - require:
      - pkg: spark-history-server
      - cmd: history-dir
      - file: /mnt/spark/logs
      - cmd: spark-history-server-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_spark_keytabs
      {% endif %}
    - watch:
      - file: /etc/spark/conf/spark-history-server.conf
      - file: /etc/spark/conf/spark-env.sh
      - file: /etc/default/spark
