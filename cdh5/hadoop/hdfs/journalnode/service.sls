{% set journal_dir = salt['pillar.get']('cdh5:dfs:journal_dir', '/mnt/hadoop/hdfs/jn') %}


# Make sure the journal data directory exists if necessary
cdh5_journal_dir:
  cmd.run:
    - name: 'mkdir -p {{ journal_dir }} && chown -R hdfs:hdfs `dirname {{ journal_dir }}`'
    - unless: 'test -d {{ journal_dir }}'
    - require:
      - pkg: hadoop-hdfs-journalnode
      - file: /etc/hadoop/conf
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

##
# Starts the journalnode service.
#
# Depends on: JDK7
##
hadoop-hdfs-journalnode-svc:
  service.running:
    - name: hadoop-hdfs-journalnode
    - enable: true
    - require:
      - pkg: hadoop-hdfs-journalnode
      - cmd: cdh5_journal_dir
      - cmd: hadoop-hdfs-journalnode-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf
