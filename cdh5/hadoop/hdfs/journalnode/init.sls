# From cloudera, cdh5 requires JDK7, so include it along with the 
# cdh5 repository to install their packages.

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:journalnode:start_service', True) %}
  - cdh5.hadoop.hdfs.journalnode.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.hdfs.security
  {% endif %}

##
# Installs the journalnode package for high availability
#
# Depends on: JDK7
##
hadoop-hdfs-journalnode:
  pkg.installed:
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

hadoop-hdfs-journalnode-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-hdfs-journalnode"
    - require:
      - pkg: hadoop-hdfs-journalnode
