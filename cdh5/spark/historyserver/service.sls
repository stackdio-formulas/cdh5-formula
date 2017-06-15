

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
# to require this state to be sure we have a krb ticket
{% if pillar.cdh5.security.enable %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require_in:
      - cmd: history-dir

hdfs_kdestroy:
  cmd:
    - run
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
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p /user/spark/applicationHistory && hdfs dfs -chown -R spark:spark /user/spark && hdfs dfs -chmod 1777 /user/spark/applicationHistory'
    - require:
      - pkg: spark-history-server


/etc/spark/conf/spark-defaults.conf:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-defaults.conf
    - template: jinja
    - require:
      - pkg: spark-history-server


spark-history-server-svc:
  service:
    - running
    - name: spark-history-server
    - require:
      - pkg: spark-history-server
      - cmd: history-dir
    - watch:
      - file: /etc/spark/conf/spark-defaults.conf
