{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: hadoop-hdfs-namenode-svc
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
      - cmd: init_standby_namenode
      - file: /etc/hadoop/conf
    - watch:
      - file: /etc/hadoop/conf

##
# Sets this namenode as the "Standby" namenode
##
activate_standby:
  cmd:
    - run
    - name: 'hdfs haadmin -transitionToStandby nn2'
    - user: hdfs
    - group: hdfs
    - require:
      - service: hadoop-hdfs-namenode-svc

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
init_standby_namenode:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs namenode -bootstrapStandby -force -nonInteractive'
    - unless: 'test -d {{ dfs_name_dir }}/current'
    - require:
      - cmd: cdh5_dfs_dirs
