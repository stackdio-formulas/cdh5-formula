{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/hadoop/mapred/local') %}
{% set dfs_data_dir = salt['pillar.get']('cdh5:dfs:data_dir', '/mnt/hadoop/hdfs/data') %}

# From cloudera, CDH5 requires JDK7, so include it along with the 
# CDH5 repository to install their packages.
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  - cdh5.hadoop.client

extend:
  /etc/hadoop/conf:
    file:
      - require:
        - pkg: hadoop-hdfs-datanode
        - pkg: hadoop-yarn-nodemanager
        - pkg: hadoop-mapreduce

##
# Installs the datanode service
#
# Depends on: JDK7
#
##
hadoop-hdfs-datanode:
  pkg:
    - installed 
    - require:
      - module: cdh5_refresh_db
  service:
    - running
    - require: 
      - pkg: hadoop-hdfs-datanode
      - cmd: dfs_data_dir
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Installs the yarn nodemanager service
#
# Depends on: JDK7
##
hadoop-yarn-nodemanager:
  pkg:
    - installed 
    - require:
      - module: cdh5_refresh_db
  service:
    - running
    - require: 
      - pkg: hadoop-yarn-nodemanager
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Installs the mapreduce service
#
# Depends on: JDK7
##
hadoop-mapreduce:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
  service:
    - running
    - require:
      - pkg: hadoop-mapreduce
      - cmd: datanode_mapred_local_dirs
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

# make the local storage directories
datanode_mapred_local_dirs:
  cmd:
    - run
    - name: 'mkdir -p {{ mapred_local_dir }} && chmod -R 755 {{ mapred_local_dir }} && chown -R mapred:mapred {{ mapred_local_dir }}'
    - unless: "test -d {{ mapred_local_dir }} && [ `stat -c '%U' {{ mapred_local_dir }}` == 'mapred' ]"
    - require:
      - pkg: hadoop-0.20-mapreduce-tasktracker

# make the hdfs data directories
dfs_data_dir:
  cmd:
    - run
    - name: 'mkdir -p {{ dfs_data_dir }} && chmod -R 755 {{ dfs_data_dir }} && chown -R hdfs:hdfs {{ dfs_data_dir }}'
    - unless: "test -d {{ dfs_data_dir }} && [ `stat -c '%U' {{ dfs_data_dir }}` == 'hdfs' ]"
    - require:
      - pkg: hadoop-hdfs-datanode

