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
hdfs-kinit:
  cmd.run:
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require_in:
      - cmd: hbase-init

hdfs-kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hdfs-kinit
      - cmd: hbase-init
    - require_in:
      - service: hbase-master-svc

hbase-kinit:
  cmd.run:
    - name: 'kinit -kt /etc/hbase/conf/hbase.keytab hbase/{{ grains.fqdn }}'
    - user: hbase
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hbase_keytab

hbase-kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: hbase
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hbase-kinit
    - require_in:
      - service: hbase-master-svc
{% endif %}

hbase-init:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p /hbase && hdfs dfs -chown hbase:hbase /hbase'
    - require:
      - pkg: hadoop-client
      - pkg: hbase-master

{% if kms %}
create_hbase_key:
  cmd.run:
    - user: hbase
    - name: 'hadoop key create hbase-key'
    - unless: 'hadoop key list | grep hbase-key'
    {% if pillar.cdh5.security.enable %}
    - require:
      - cmd: hbase-kinit
    - require_in:
      - cmd: hbase-kdestroy
    {% endif %}

create_hbase_zone:
  cmd.run:
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName hbase-key -path /hbase'
    - unless: 'hdfs crypto -listZones | grep /hbase'
    - require:
      - cmd: create_hbase_key
      - cmd: hbase-init
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs-kinit
      {% endif %}
    - require_in:
      - service: hbase-master-svc
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs-kdestroy
      {% endif %}
{% endif %}

hbase-master-svc:
  service.running:
    - name: hbase-master
    - require: 
      - pkg: hbase-master
      - cmd: hbase-init
      - file: {{ pillar.cdh5.hbase.tmp_dir }}
      - file: {{ pillar.cdh5.hbase.log_dir }}
      - cmd: hbase-master-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      - cmd: chown-hbase-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hbase_keytab
      {% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

hbase-thrift-svc:
  service.running:
    - name: hbase-thrift
    - require:
      - service: hbase-master-svc
      - cmd: hbase-thrift-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      - cmd: chown-hbase-keystore
      {% endif %}
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
