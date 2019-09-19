
# From cloudera, CDH5 requires JDK7, so include it along with the 
# CDH5 repository to install their packages.
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:datanode:start_service', True) %}
  - cdh5.hadoop.hdfs.datanode.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.hdfs.security
  {% endif %}

##
# Installs the datanode service
#
# Depends on: JDK7
#
##
hadoop-hdfs-datanode:
  pkg.installed:
    - pkgs:
      - hadoop-hdfs-datanode
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

hadoop-hdfs-datanode-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-hdfs-datanode"
    - require:
      - pkg: hadoop-hdfs-datanode

{% if pillar.cdh5.security.enable %}
/etc/default/hadoop-hdfs-datanode:
  file.managed:
    - source: salt://cdh5/etc/default/hadoop-hdfs-datanode
    - template: jinja
    - makedirs: true
    - user: root
    - group: root
    - file_mode: 644
    - require:
      - pkg: hadoop-hdfs-datanode
{% endif %}

