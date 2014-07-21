# 
# Start the HBase master service
#
include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.zookeeper
  - cdh5.hbase.conf

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: hbase-master-svc
        - service: hbase-thrift-svc
{% endif %}

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hadoop fs' commands will need
# to require this state to be sure we have a krb ticket
{% if salt['pillar.get']('cdh5:security:enable', False) %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - require:
      - cmd: generate_hbase_keytabs
{% endif %}

hbase-init:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir /hbase && hadoop fs -chown hbase:hbase /hbase'
    - unless: 'hadoop fs -test -d /hbase'
    - require:
      - pkg: hadoop-client
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: hdfs_kinit
{% endif %}

hbase-master-svc:
  service:
    - running
    - name: hbase-master
    - require: 
      - pkg: hbase-master
      - cmd: hbase-init
      - service: zookeeper-server
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: {{ pillar.cdh5.hbase.log_dir }}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hbase_keytabs
{% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

hbase-thrift-svc:
  service:
    - running
    - name: hbase-thrift
    - require:
      - service: hbase-master

