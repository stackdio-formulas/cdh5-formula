{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}

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

# Initialize the standby namenode, which will sync the configuration
# and metadata from the active namenode
{% set bootstrap = "hdfs namenode -bootstrapStandby -force -nonInteractive" %}
init_standby_namenode:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: '{{ bootstrap }} || sleep 30 && {{ bootstrap }}'
    - unless: 'test -d {{ dfs_name_dir }}/current'
    - require:
      - cmd: cdh5_dfs_dirs
    {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
    {% endif %}

# Start up the ZKFC
hadoop-hdfs-zkfc-svc:
  service:
    - running
    - name: hadoop-hdfs-zkfc
    - require:
      - pkg: hadoop-hdfs-zkfc
      - cmd: init_standby_namenode
    - watch:
      - file: /etc/hadoop/conf

##
# Starts the namenode service on a standby namenode
#
# Depends on: JDK7
##
hadoop-hdfs-namenode-svc:
  service:
    - running
    - name: hadoop-hdfs-namenode
    - require:
      - pkg: hadoop-hdfs-namenode
      - cmd: init_standby_namenode
    - watch:
      - file: /etc/hadoop/conf
