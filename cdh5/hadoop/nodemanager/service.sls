{% set yarn_local_dir = salt['pillar.get']('cdh5:yarn:local_dirs', '/mnt/hadoop/yarn/local') %}
{% set yarn_log_dir = salt['pillar.get']('cdh5:yarn:log_dirs', '/mnt/hadoop/yarn/logs') %}


# make the local storage directories
datanode_yarn_local_dirs:
  cmd:
    - run
    - name: 'for dd in `echo {{ yarn_local_dir}} | sed "s/,/\n/g"`; do mkdir -p $dd && chmod -R 755 $dd && chown -R yarn:yarn `dirname $dd`; done'
    - unless: "test -d `echo {{ yarn_local_dir }} | awk -F, '{print $1}'` && [ $(stat -c '%U' $(echo {{ yarn_local_dir }} | awk -F, '{print $1}')) == 'yarn' ]"
    - require:
      - pkg: hadoop-yarn-nodemanager

# make the log storage directories
datanode_yarn_log_dirs:
  cmd:
    - run
    - name: 'for dd in `echo {{ yarn_log_dir}} | sed "s/,/\n/g"`; do mkdir -p $dd && chmod -R 755 $dd && chown -R yarn:yarn `dirname $dd`; done'
    - unless: "test -d `echo {{ yarn_log_dir }} | awk -F, '{print $1}'` && [ $(stat -c '%U' $(echo {{ yarn_log_dir }} | awk -F, '{print $1}')) == 'yarn' ]"
    - require:
      - pkg: hadoop-yarn-nodemanager

##
# Starts the yarn nodemanager service
#
# Depends on: JDK7
##
hadoop-yarn-nodemanager-svc:
  service:
    - running
    - name: hadoop-yarn-nodemanager
    - enable: true
    - require: 
      - pkg: hadoop-yarn-nodemanager
      - cmd: datanode_yarn_local_dirs
      - cmd: datanode_yarn_log_dirs
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - file: /etc/default/hadoop-hdfs-datanode
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf


