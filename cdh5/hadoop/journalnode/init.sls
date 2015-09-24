# From cloudera, cdh5 requires JDK7, so include it along with the 
# cdh5 repository to install their packages.

{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:journalnode:start_service', True) %}
  - cdh5.hadoop.journalnode.service
  {% endif %}
  {% if kms %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.hadoop.security
  {% endif %}

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
