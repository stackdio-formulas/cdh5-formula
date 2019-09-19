{% set dfs_data_dir = salt['pillar.get']('cdh5:dfs:data_dir', '/mnt/hadoop/hdfs/data') %}

# make the hdfs data directories
dfs_data_dir:
  cmd.run:
    - name: 'for dd in `echo {{ dfs_data_dir }} | sed "s/,/\n/g"`; do mkdir -p $dd && chmod -R 755 $dd && chown -R hdfs:hdfs `dirname $dd`; done'
    - unless: "test -d `echo {{ dfs_data_dir }} | awk -F, '{print $1}'` && [ $(stat -c '%U' $(echo {{ dfs_data_dir }} | awk -F, '{print $1}')) == 'hdfs' ]"
    - require:
      - pkg: hadoop-hdfs-datanode

##
# Starts the datanode service
#
# Depends on: JDK7
#
##
hadoop-hdfs-datanode-svc:
  service.running:
    - name: hadoop-hdfs-datanode
    - enable: true
    - require: 
      - pkg: hadoop-hdfs-datanode
      - cmd: dfs_data_dir
      - cmd: hadoop-hdfs-datanode-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - file: /etc/default/hadoop-hdfs-datanode
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf

