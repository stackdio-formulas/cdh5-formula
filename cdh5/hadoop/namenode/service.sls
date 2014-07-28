{%- set hann = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.namenode.standby', 'grains.items', 'compound') -%}
{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}
{% set journal_dir = salt['pillar.get']('cdh5:dfs:journal_dir', '/mnt/hadoop/hdfs/jn') %}
{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/hadoop/mapred/local') %}
{% set mapred_system_dir = salt['pillar.get']('cdh5:mapred:system_dir', '/hadoop/system/mapred') %}
{% set mapred_staging_dir = '/user/history' %}
{% set mapred_log_dir = '/var/log/hadoop-yarn' %}

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: hadoop-hdfs-namenode-svc
        - service: hadoop-yarn-resourcemanager-svc
        - service: hadoop-mapreduce-historyserver-svc
{% endif %}

##
# Starts the namenode service.
#
# Depends on: JDK7
##
hadoop-hdfs-namenode-svc:
  service:
    - running
    - name: hadoop-hdfs-namenode
    - require: 
      - pkg: hadoop-hdfs-namenode
      # Make sure HDFS is initialized before the namenode
      # is started
      - cmd: init_hdfs
      - file: /etc/hadoop/conf
{% if hann %}
      - service: hadoop-hdfs-journalnode-svc
{% endif %}
    - watch:
      - file: /etc/hadoop/conf

{% if hann %}
##
# Starts the journalnode service.
#
# Depends on: JDK7
##
hadoop-hdfs-journalnode-svc:
  service:
    - running
    - name: hadoop-hdfs-journalnode
    - require: 
      - pkg: hadoop-hdfs-journalnode
      - file: /etc/hadoop/conf
{% if hann %}
      - cmd: cdh5_journal_dir
{% endif %}
    - watch:
      - file: /etc/hadoop/conf
{% endif %}

##
# Starts yarn resourcemanager service.
#
# Depends on: JDK7
##
hadoop-yarn-resourcemanager-svc:
  service:
    - running
    - name: hadoop-yarn-resourcemanager
    - require: 
      - pkg: hadoop-yarn-resourcemanager
      - service: hadoop-hdfs-namenode
#      - cmd: namenode_mapred_local_dirs
#      - cmd: mapred_system_dirs
      - cmd: hdfs_mapreduce_var_dir
      - cmd: hdfs_mapreduce_log_dir
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Installs the mapreduce historyserver service and starts it.
#
# Depends on: JDK7
##
hadoop-mapreduce-historyserver-svc:
  service:
    - running
    - name: hadoop-mapreduce-historyserver
    - require:
      - pkg: hadoop-mapreduce-historyserver
      - service: hadoop-hdfs-namenode
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Installs the hadoop job tracker service and starts it.
#
# Depends on: JDK7
##
#hadoop-yarn-proxyserver-svc:
#  service:
#    - running
#    - name: hadoop-yarn-proxyserver
#    - require:
#      - pkg: hadoop-yarn-proxyserver
#      - file: /etc/hadoop/conf
#    - watch:
#      - file: /etc/hadoop/conf
#
#
# Make sure the namenode metadata directory exists
# and is owned by the hdfs user
cdh5_dfs_dirs:
  cmd:
    - run
    - name: 'mkdir -p {{ dfs_name_dir }} && chown -R hdfs:hdfs `dirname {{ dfs_name_dir }}`'
    - unless: 'test -d {{ dfs_name_dir }}'
    - require:
      - pkg: hadoop-hdfs-namenode
      - file: /etc/hadoop/conf
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
{% endif %}

{% if hann %}
# Make sure the journal data directory exists if necessary
cdh5_journal_dir:
  cmd:
    - run
    - name: 'mkdir -p {{ journal_dir }} && chown -R hdfs:hdfs `dirname {{ journal_dir }}`'
    - unless: 'test -d {{ journal_dir }}'
    - require:
      - pkg: hadoop-hdfs-namenode
      - file: /etc/hadoop/conf
{% endif %}

# Initialize HDFS. This should only run once, immediately
# following an install of hadoop.
init_hdfs:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs namenode -format'
    - unless: 'test -d {{ dfs_name_dir }}/current'
    - require:
      - cmd: cdh5_dfs_dirs

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hadoop fs' commands will need
# to require this state to be sure we have a krb ticket
{% if salt['pillar.get']('cdh5:security:enable', False) %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - require:
      - service: hadoop-hdfs-namenode-svc
      - cmd: generate_hadoop_keytabs
{% endif %}

# HDFS tmp directory
hdfs_tmp_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir /tmp && hadoop fs -chmod -R 1777 /tmp'
    - unless: 'hadoop fs -test -d /tmp'
    - require:
      - service: hadoop-hdfs-namenode-svc
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
{% endif %}

# HDFS MapReduce log directories
hdfs_mapreduce_log_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir -p {{ mapred_log_dir }} && hadoop fs -chmod 1777 {{ mapred_log_dir }} && hadoop fs -chown -R yarn `dirname {{ mapred_log_dir }}`'
    - unless: 'hadoop fs -test -d {{ mapred_log_dir }}'
    - require:
      - service: hadoop-hdfs-namenode-svc
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
{% endif %}

# HDFS MapReduce var directories
hdfs_mapreduce_var_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir -p {{ mapred_staging_dir }} && hadoop fs -chmod 1777 {{ mapred_staging_dir }} && hadoop fs -chown -R yarn `dirname {{ mapred_staging_dir }}`'
    - unless: 'hadoop fs -test -d {{ mapred_staging_dir }}'
    - require:
      - service: hadoop-hdfs-namenode-svc
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
{% endif %}

# set permissions at the root level of HDFS so any user can write to it
hdfs_permissions:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -chmod 777 /'
    - require:
      - service: hadoop-yarn-resourcemanager-svc
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
{% endif %}


# MR local directory
#namenode_mapred_local_dirs:
#  cmd:
#    - run
#    - name: 'mkdir -p {{ mapred_local_dir }} && chown -R mapred:hadoop {{ mapred_local_dir }}'
#    - unless: 'test -d {{ mapred_local_dir }}'
#    - require:
#      - pkg: hadoop-hdfs-namenode-svc
#      - pkg: hadoop-yarn-resourcemanager-svc

# MR system directory
#mapred_system_dirs:
#  cmd:
#    - run
#    - user: hdfs
#    - group: hdfs
#    - name: 'hadoop fs -mkdir {{ mapred_system_dir }} && hadoop fs -chown mapred:hadoop {{ mapred_system_dir }}'
#    - unless: 'hadoop fs -test -d {{ mapred_system_dir }}'
#    - require:
#      - service: hadoop-hdfs-namenode-svc
