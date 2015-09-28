##
# Standby NameNode
##
{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}


include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  - cdh5.hadoop.standby-namenode.service
{% endif %}
{% if kms %}
  - cdh5.hadoop.encryption
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
{% endif %}

hadoop-hdfs-namenode:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if kms %}
      - cmd: create-keystore
      {% endif %}
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

hadoop-yarn-resourcemanager:
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

# we need the mapred user on the standby namenode for job history to work;
# It's easiest to just do this by installing mapreduce
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


hadoop-hdfs-zkfc:
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
