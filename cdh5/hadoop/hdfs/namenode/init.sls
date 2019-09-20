{% set standby = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.hdfs.standby-namenode', 'grains.items', 'compound') %}

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:namenode:start_service', True) %}
  - cdh5.hadoop.hdfs.namenode.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.hdfs.security
  {% endif %}

##
# Installs the necessary packages for the namenode to operate.
#
# Depends on: JDK7
##
hadoop-hdfs-namenode:
  pkg.installed:
    - pkgs:
      - hadoop-hdfs-namenode
      - hadoop-mapreduce
      - spark-core
      {% if standby %}
      # Only for HA
      - hadoop-hdfs-zkfc
      {% endif %}
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

hadoop-hdfs-namenode-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-hdfs-namenode"
    - require:
      - pkg: hadoop-hdfs-namenode


{% if standby %}
hadoop-hdfs-zkfc-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-hdfs-zkfc"
    - require:
      - pkg: hadoop-hdfs-namenode
{% endif %}
