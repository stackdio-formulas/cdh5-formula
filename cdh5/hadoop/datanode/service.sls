{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/yarn') %}
{% set dfs_data_dir = salt['pillar.get']('cdh5:dfs:data_dir', '/mnt/hadoop/hdfs/data') %}

##
# Starts the datanode service
#
# Depends on: JDK7
#
##
hadoop-hdfs-datanode-svc:
  service:
    - running
    - name: hadoop-hdfs-datanode
    - require: 
      - pkg: hadoop-hdfs-datanode
      - cmd: dfs_data_dir
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Starts the yarn nodemanager service
#
# Depends on: JDK7
##
hadoop-yarn-nodemanager-svc:
  service:
    - running
    - name: hadoop-yarn-nodemanager
    - require: 
      - pkg: hadoop-yarn-nodemanager
      - cmd: datanode_mapred_local_dirs
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Starts the mapreduce service
#
# Depends on: JDK7
##
#hadoop-mapreduce-svc:
#  service:
#    - running
#    - name: hadoop-mapreduce
#    - require:
#      - pkg: hadoop-mapreduce
#      - cmd: datanode_mapred_local_dirs
#      - file: /etc/hadoop/conf
#    - watch:
#      - file: /etc/hadoop/conf

# make the local storage directories
datanode_mapred_local_dirs:
  cmd:
    - run
    - name: 'mkdir -p {{ mapred_local_dir }} && chmod -R 755 {{ mapred_local_dir }} && chown -R yarn:yarn {{ mapred_local_dir }}'
    - unless: "test -d {{ mapred_local_dir }} && [ `stat -c '%U' {{ mapred_local_dir }}` == 'yarn' ]"
    - require:
      - pkg: hadoop-yarn-nodemanager
      - service: hadoop-yarn-nodemanager-svc

# make the hdfs data directories
dfs_data_dir:
  cmd:
    - run
    - name: 'mkdir -p {{ dfs_data_dir }} && chmod -R 755 {{ dfs_data_dir }} && chown -R hdfs:hdfs {{ dfs_data_dir }}'
    - unless: "test -d {{ dfs_data_dir }} && [ `stat -c '%U' {{ dfs_data_dir }}` == 'hdfs' ]"
    - require:
      - pkg: hadoop-hdfs-datanode
      - service: hadoop-hdfs-datanode-svc


