{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}
#
# Start the HBase master service
#

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
# to require this state to be sure we have a krb ticket
{% if pillar.cdh5.security.enable %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hbase_keytabs

hbase_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hbase/conf/hbase.keytab hbase/{{ grains.fqdn }}'
    - user: hbase
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hbase_keytabs
{% endif %}

hbase-init:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir /hbase && hdfs dfs -chown hbase:hbase /hbase'
    - unless: 'hdfs dfs -test -d /hbase'
    - require:
      - pkg: hadoop-client
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kinit
      {% endif %}

{% if kms %}
create_hbase_key:
  cmd:
    - run
    - user: hbase
    - name: 'hadoop key create hbase'
    - unless: 'hadoop key list | grep hbase'
    {% if pillar.cdh5.security.enable %}
    - require:
      - cmd: hbase_kinit
    {% endif %}

create_hbase_zone:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName hbase -path /hbase'
    - unless: 'hdfs crypto -listZones | grep /hbase'
    - require:
      - cmd: create_hbase_key
      - cmd: hbase-init
    - require_in:
      - service: hbase-master-svc
{% endif %}

hbase-master-svc:
  service:
    - running
    - name: hbase-master
    - require: 
      - pkg: hbase-master
      - cmd: hbase-init
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: {{ pillar.cdh5.hbase.log_dir }}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hbase_keytabs
      {% endif %}
      {% if salt['pillar.get']('cdh5:hbase:manage_zk', True) %}
      - service: zookeeper-server-svc
      {% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

hbase-thrift-svc:
  service:
    - running
    - name: hbase-thrift
    - require:
      - service: hbase-master-svc
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

