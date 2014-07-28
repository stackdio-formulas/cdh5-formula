{%- set hann = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.namenode.standby', 'grains.items', 'compound') -%}
{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}
{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/hadoop/mapred/local') %}
{% set mapred_system_dir = salt['pillar.get']('cdh5:mapred:system_dir', '/hadoop/system/mapred') %}
{% set mapred_staging_dir = '/user/history' %}
{% set mapred_log_dir = '/var/log/hadoop-yarn' %}

# From cloudera, cdh5 requires JDK7, so include it along with the 
# cdh5 repository to install their packages.

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  - cdh5.hadoop.namenode.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.hadoop.security
{% endif %}

extend:
  /etc/hadoop/conf:
    file:
      - require:
        - pkg: hadoop-hdfs-namenode
        - pkg: hadoop-yarn-resourcemanager 
        - pkg: hadoop-mapreduce-historyserver
#        - pkg: hadoop-yarn-proxyserver
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  load_admin_keytab:
    module:
      - require:
        - file: /etc/krb5.conf
        - file: /etc/hadoop/conf
  generate_hadoop_keytabs:
    cmd:
      - require:
        - pkg: hadoop-hdfs-namenode
        - pkg: hadoop-yarn-resourcemanager
        - pkg: hadoop-mapreduce-historyserver
        - module: load_admin_keytab
{% endif %}

##
# Installs the namenode package.
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

{% if hann %}
##
# Installs the journalnode package for high availability
#
# Depends on: JDK7
##
hadoop-hdfs-journalnode:
  pkg:
    - installed 
    - require:
      - module: cdh5_refresh_db
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

##
# Installs the hadoop job tracker package.
#
# Depends on: JDK7
##
#hadoop-yarn-proxyserver:
#  pkg:
#    - installed
#    - require:
#      - module: cdh5_refresh_db
#
