##
# Standby NameNode
##


include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  - cdh5.hadoop.yarn.standby-resourcemanager.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.yarn.security
  {% endif %}

hadoop-yarn-resourcemanager:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
