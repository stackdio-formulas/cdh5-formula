{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}
{% set mapred_staging_dir = '/user/history' %}
{% set mapred_log_dir = '/var/log/hadoop-yarn' %}

##
# Starts the historyserver service.
#
# Depends on: JDK7
##

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
# to require this state to be sure we have a krb ticket
{% if pillar.cdh5.security.enable %}
hdfs_kinit_for_mapred:
  cmd.run:
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hadoop_keytabs
    - require_in:
      - cmd: hdfs_mapreduce_log_dir
      - cmd: hdfs_mapreduce_var_dir

hdfs_kdestroy_for_mapred:
  cmd.run:
    - name: 'kdestroy'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hdfs_kinit_for_mapred
      - cmd: hdfs_mapreduce_log_dir
      - cmd: hdfs_mapreduce_var_dir

{% endif %}

# HDFS MapReduce log directories
hdfs_mapreduce_log_dir:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p {{ mapred_log_dir }} && hdfs dfs -chown yarn:hadoop {{ mapred_log_dir }}'
    - unless: 'hdfs dfs -test -d {{ mapred_log_dir }}'

# HDFS MapReduce var directories
hdfs_mapreduce_var_dir:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p {{ mapred_staging_dir }} && hdfs dfs -chmod -R 1777 {{ mapred_staging_dir }} && hdfs dfs -chown mapred:hadoop {{ mapred_staging_dir }}'
    - unless: 'hdfs dfs -test -d {{ mapred_staging_dir }}'

{% if kms %}

{% if pillar.cdh5.security.enable %}
mapred_kinit:
  cmd.run:
    - name: 'kinit -kt /etc/hadoop/conf/mapred.keytab mapred/{{ grains.fqdn }}'
    - user: mapred
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hadoop_keytabs
    - require_in:
      - cmd: create_mapred_key
      - cmd: create_mapred_zone

mapred_kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: mapred
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: mapred_kinit
      - cmd: create_mapred_key
      - cmd: create_mapred_zone
{% endif %}

create_mapred_key:
  cmd.run:
    - user: mapred
    - name: 'hadoop key create mapred-key'
    - unless: 'hadoop key list | grep mapred-key'
    - require:
      - file: /etc/hadoop/conf

create_mapred_zone:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName mapred-key -path {{ mapred_staging_dir }}'
    - unless: 'hdfs crypto -listZones | grep {{ mapred_staging_dir }}'
    - require:
      - cmd: create_mapred_key
      - cmd: hdfs_mapreduce_var_dir
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kinit_for_mapred
      {% endif %}
    - require_in:
      - service: hadoop-mapreduce-historyserver-svc
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kdestroy_for_mapred
      {% endif %}
{% endif %}

##
# Installs the mapreduce historyserver service and starts it.
#
# Depends on: JDK7
##
hadoop-mapreduce-historyserver-svc:
  service:
    - running
    - name: hadoop-mapreduce-historyserver
    - enable: true
    - require:
      - pkg: hadoop-mapreduce-historyserver
      - cmd: hdfs_mapreduce_var_dir
      - cmd: hdfs_mapreduce_log_dir
      - cmd: hadoop-mapreduce-historyserver-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf
