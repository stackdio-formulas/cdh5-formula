
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:historyserver:start_service', True) %}
  - cdh5.hadoop.mapreduce.historyserver.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.mapreduce.security
  {% endif %}

##
# Installs the mapreduce historyserver package.
#
# Depends on: JDK7
##
hadoop-mapreduce-historyserver:
  pkg.installed:
    - pkgs:
      - hadoop-mapreduce-historyserver
      - spark-core
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if pillar.cdh5.encryption.enable %}
      - file: /etc/hadoop/conf/hadoop.key
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

hadoop-mapreduce-historyserver-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-mapreduce-historyserver"
    - require:
      - pkg: hadoop-mapreduce-historyserver
