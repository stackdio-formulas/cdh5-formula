{% set journal_dir = salt['pillar.get']('cdh5:dfs:journal_dir', '/mnt/hadoop/hdfs/jn') %}
{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}


# Make sure the journal data directory exists if necessary
cdh5_journal_dir:
  cmd:
    - run
    - name: 'mkdir -p {{ journal_dir }} && chown -R hdfs:hdfs `dirname {{ journal_dir }}`'
    - unless: 'test -d {{ journal_dir }}'
    - require:
      - pkg: hadoop-hdfs-journalnode
      - file: /etc/hadoop/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

##
# Starts the journalnode service.
#
# Depends on: JDK7
##
hadoop-hdfs-journalnode-svc:
  service:
    - running
    - name: hadoop-hdfs-journalnode
    - require:
      - pkg: hadoop-hdfs-journalnode
      - cmd: cdh5_journal_dir
      {% if kms %}
      - cmd: chown-keystore
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf
