
# From cloudera, CDH5 requires JDK7, so include it along with the 
# CDH5 repository to install their packages.
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  - cdh5.hadoop.client
{% if salt['pillar.get']('cdh5:datanode:start_service', True) %}
  - cdh5.hadoop.datanode.service
{% endif %}

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


