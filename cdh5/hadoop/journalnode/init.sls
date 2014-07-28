# From cloudera, cdh5 requires JDK7, so include it along with the 
# cdh5 repository to install their packages.

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:journalnode:start_service', True) %}
  - cdh5.hadoop.journalnode.service
{% endif %}

extend:
  /etc/hadoop/conf:
    file:
      - require:
        - pkg: hadoop-hdfs-journalnode

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
