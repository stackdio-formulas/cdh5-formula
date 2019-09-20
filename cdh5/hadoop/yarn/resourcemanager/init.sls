
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:resourcemanager:start_service', True) %}
  - cdh5.hadoop.yarn.resourcemanager.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.yarn.security
  {% endif %}

##
# Installs the yarn resourcemanager package.
#
# Depends on: JDK
##
hadoop-yarn-resourcemanager:
  pkg:
    - installed
    - pkgs:
      - hadoop-yarn-resourcemanager
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

hadoop-yarn-resourcemanager-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-yarn-resourcemanager"
    - require:
      - pkg: hadoop-yarn-resourcemanager
