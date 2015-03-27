{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}
{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/hadoop/mapred/local') %}
{% set mapred_system_dir = salt['pillar.get']('cdh5:mapred:system_dir', '/hadoop/system/mapred') %}
{% set mapred_staging_dir = '/user/history' %}
{% set mapred_log_dir = '/var/log/hadoop-yarn' %}

##
# Adding high-availability to the mix makes things a bit more complicated.
# First, the NN and HA NN need to connect and sync up before anything else
# happens. Right now, that's hard since we can't parallelize the two
# state runs...so, what we have to do instead is make the HA NameNode also
# be a regular NameNode, and tweak the regular SLS to install both, at the
# same time.
##

##
# This is a HA NN, reduce the normal NN state down to all we need
# for the standby NameNode
##
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  {% if 'cdh5.hadoop.standby' in grains.roles %}
  - cdh5.hadoop.standby.service
  {% else %}
  - cdh5.hadoop.namenode.service
  {% endif %}
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
{% endif %}

##
# Installs the namenode package.  This happens on both regular and standy namenodes.
#
# Depends on: JDK7
##
hadoop-hdfs-namenode:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/krb5.conf
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

{% if 'cdh5.hadoop.standby' in grains.roles %}

# we need a mapred user on the standby namenode for job history to work; if the
# namenode state is not included we want to add it manually
mapred_group:
  group:
    - present
    - name: mapred

hadoop_group:
  group:
    - present
    - name: hadoop

mapred_user:
  user:
    - present
    - name: mapred
    - fullname: Hadoop MapReduce
    - shell: /bin/bash
    - home: /var/lib/hadoop-mapreduce
    - groups:
      - mapred
      - hadoop
    - require:
      - group: mapred_group
      - group: hadoop_group

##
# END HA NN
##

# NOT a HA NN...continue like normal with the rest of the state
{% else %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
extend:
  load_admin_keytab:
    module:
      - require:
        - file: /etc/krb5.conf
        - file: /etc/hadoop/conf
  generate_hadoop_keytabs:
    cmd:
      - require:
        - module: load_admin_keytab
{% endif %}

##
# Installs the yarn resourcemanager package.
#
# Depends on: JDK7
##
hadoop-yarn-resourcemanager:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/krb5.conf
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

##
# Installs the mapreduce historyserver package.
#
# Depends on: JDK7
##
hadoop-mapreduce-historyserver:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/krb5.conf
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

{% endif %}
##
# END OF REGULAR NAMENODE
##
