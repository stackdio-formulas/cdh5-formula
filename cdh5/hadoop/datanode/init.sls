
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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
{% endif %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
extend:
  load_admin_keytab:
    module:
      - require:
        - file: krb5_conf_file
        - file: /etc/hadoop/conf
  generate_hadoop_keytabs:
    cmd:
      - require:
        - module: load_admin_keytab
{% endif %}

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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: krb5_conf_file
{% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

{% if salt['pillar.get']('cdh5:security:enable', False) %}
/etc/default/hadoop-hdfs-datanode:
  file:
    - managed
    - source: salt://cdh5/etc/default/hadoop-hdfs-datanode
    - template: jinja
    - makedirs: true
    - user: root
    - group: root
    - file_mode: 644
    - require:
      - pkg: hadoop-hdfs-datanode
{% endif %}

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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: krb5_conf_file
{% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: krb5_conf_file
{% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}


