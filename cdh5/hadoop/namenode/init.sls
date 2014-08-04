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
{% if 'cdh5.hadoop.standby' in grains.roles %}
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  - cdh5.hadoop.standby.service
  {% endif %}
  {% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
  {% endif %}

extend:
  /etc/hadoop/conf:
    file:
      - require:
        - pkg: hadoop-hdfs-namenode

hadoop-hdfs-namenode:
  pkg:
    - installed 
    - require:
      - module: cdh5_refresh_db
##
# END HA NN
##

# NOT a HA NN...continue like normal with the rest of the state
{% else %}
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
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
  {% endif %}

extend:
  /etc/hadoop/conf:
    file:
      - require:
        - pkg: hadoop-hdfs-namenode
        - pkg: hadoop-yarn-resourcemanager 
        - pkg: hadoop-mapreduce-historyserver
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

{% endif %}
##
# END OF REGULAR NAMENODE
##
