{%- set standby = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.standby', 'grains.items', 'compound') -%}
{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}
{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/hadoop/mapred/local') %}
{% set mapred_system_dir = salt['pillar.get']('cdh5:mapred:system_dir', '/hadoop/system/mapred') %}
{% set mapred_staging_dir = '/user/history' %}
{% set mapred_log_dir = '/var/log/hadoop-yarn' %}

##
# Standby NN specific SLS
##
{% if 'cdh5.hadoop.standby' in grains.roles %}
include:
  - cdh5.hadoop.standby.service
##
# END STANDBY NN
##

##
# Regular NN SLS
##
{% else %}

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
    - watch:
      - file: /etc/hadoop/conf

{% if standby %}
##
# Sets this namenode as the "Active" namenode
##
# We run into a race condition sometimes where the the nn service isn't started yet on the snn,
# so we'll sleep for 30 seconds first before continuing
activate_namenode:
  cmd:
    - run
    - name: 'sleep 30 && hdfs haadmin -transitionToActive nn1'
    - user: hdfs
    - group: hdfs
    - require:
      - service: hadoop-hdfs-namenode-svc
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
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
      - service: hadoop-hdfs-namenode-svc
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
      - service: hadoop-hdfs-namenode-svc
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Make sure the namenode metadata directory exists
# and is owned by the hdfs user
##
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

# Initialize HDFS. This should only run once, immediately
# following an install of hadoop.
init_hdfs:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs namenode -format -force'
    - unless: 'test -d {{ dfs_name_dir }}/current'
    - require:
      - cmd: cdh5_dfs_dirs

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
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
    - name: 'hdfs dfs -mkdir /tmp && hdfs dfs -chmod -R 1777 /tmp'
    - unless: 'hdfs dfs -test -d /tmp'
    - require:
      - service: hadoop-hdfs-namenode-svc
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
      {% if standby %}
      - cmd: activate_namenode 
      {% endif %}

# HDFS MapReduce log directories
hdfs_mapreduce_log_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p {{ mapred_log_dir }} && hdfs dfs -chown yarn:mapred {{ mapred_log_dir }}'
    - unless: 'hdfs dfs -test -d {{ mapred_log_dir }}'
    - require:
      - service: hadoop-hdfs-namenode-svc
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
      {% if standby %}
      - cmd: activate_namenode 
      {% endif %}

# HDFS MapReduce var directories
hdfs_mapreduce_var_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p {{ mapred_staging_dir }} && hdfs dfs -chmod -R 1777 {{ mapred_staging_dir }} && hdfs dfs -chown mapred:hadoop {{ mapred_staging_dir }}'
    - unless: 'hdfs dfs -test -d {{ mapred_staging_dir }}'
    - require:
      - service: hadoop-hdfs-namenode-svc
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
      {% if standby %}
      - cmd: activate_namenode 
      {% endif %}

# create a user directory owned by the stack user
{% set user = pillar.__stackdio__.username %}
hdfs_user_dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir /user/{{ user }} && hdfs dfs -chown {{ user }}:{{ user }} /user/{{ user }}'
    - unless: 'hdfs dfs -test -d /user/{{ user }}'
    - require:
      - service: hadoop-yarn-resourcemanager-svc
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
      {% endif %}
      {% if standby %}
      - cmd: activate_namenode 
      {% endif %}


#
##
# END REGULAR NAMENODE 
##
{% endif %}
