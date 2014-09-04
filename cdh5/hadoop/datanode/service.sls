{% set mapred_local_dir = salt['pillar.get']('cdh5:mapred:local_dir', '/mnt/yarn') %}
{% set dfs_data_dir = salt['pillar.get']('cdh5:dfs:data_dir', '/mnt/hadoop/hdfs/data') %}

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: hadoop-hdfs-datanode-svc
        - service: hadoop-yarn-nodemanager-svc
{% endif %}


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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/default/hadoop-hdfs-datanode
      - cmd: generate_hadoop_keytabs
{% endif %}
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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/default/hadoop-hdfs-datanode
      - cmd: generate_hadoop_keytabs
{% endif %}
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

# make the hdfs data directories
dfs_data_dir:
  cmd:
    - run
    - name: 'for dd in `echo {{ dfs_data_dir }} | sed "s/,/\n/g"`; do mkdir -p $dd && chmod -R 755 $dd && chown -R hdfs:hdfs $dd; done'
    - unless: "test -d `echo {{ dfs_data_dir }} | awk -F, '{print $1}'` && [ $(stat -c '%U' $(echo {{ dfs_data_dir }} | awk -F, '{print $1}')) == 'hdfs' ]"
    - require:
      - pkg: hadoop-hdfs-datanode


