{% set kms = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}
{% set packages = salt['grains.filter_by']({
   'Debian': {
      'service': 'mysql'
   },
   'RedHat': salt['grains.filter_by']({
      '6': {
         'service': 'mysqld'
      },
      '7': {
         'service': 'mariadb'
      }
   }, 'osmajorrelease')
}) %}

#
# Start the Hive service
#

# @todo move this out to its own formula
mysql-svc:
  service:
    - running
    - name: {{ packages.service }}
    - require:
      - pkg: mysql

{% if pillar.cdh5.security.enable %}
hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'

hive_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hive/conf/hive.keytab hive/{{ grains.fqdn }}'
    - user: hive
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hive_keytabs
{% endif %}

create_anonymous_user:
  cmd:
    - run
    - name: 'hdfs dfs -mkdir -p /user/anonymous && hdfs dfs -chown anonymous:anonymous /user/anonymous'
    - user: hdfs
    {% if pillar.cdh5.security.enable %}
    - require:
      - cmd: hdfs_kinit
    {% endif %}

configure_metastore:
  cmd:
    - script
    - template: jinja
    - source: salt://cdh5/hive/configure_metastore.sh
    - unless: echo "show databases" | mysql -u root | grep metastore
    - require: 
      - pkg: hive
      - service: mysql-svc

create_hive_dir:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs dfs -mkdir -p /user/{{ pillar.cdh5.hive.user }} && hdfs dfs -chown -R {{pillar.cdh5.hive.user}}:{{pillar.cdh5.hive.user}} /user/{{pillar.cdh5.hive.user}}'
    {% if pillar.cdh5.security.enable %}
    - require:
      - cmd: hdfs_kinit
    {% endif %}

{% if kms %}
create_hive_key:
  cmd:
    - run
    - user: hive
    - name: 'hadoop key create hive'
    - unless: 'hadoop key list | grep hive'
    {% if pillar.cdh5.security.enable %}
    - require:
      - cmd: hive_kinit
    {% endif %}

create_hive_zone:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs crypto -createZone -keyName hive -path /user/{{ pillar.cdh5.hive.user }}'
    - unless: 'hdfs crypto -listZones | grep /user/{{ pillar.cdh5.hive.user }}'
    - require:
      - cmd: create_hive_key
      - cmd: create_hive_dir
    - require_in:
      - service: hive-metastore
      - cmd: create_warehouse_dir
      - cmd: create_scratch_dir
{% endif %}

create_warehouse_dir:
  cmd:
    - run
    - name: 'hdfs dfs -mkdir -p /user/{{pillar.cdh5.hive.user}}/warehouse'
    - user: hive
    - require:
      - pkg: hive
      {% if pillar.cdh5.security.enable %}
      - cmd: hive_kinit
      {% endif %}

create_scratch_dir:
  cmd:
    - run
    - name: 'hdfs dfs -mkdir -p /user/{{pillar.cdh5.hive.user}}/tmp'
    - user: hive
    - require:
      - pkg: hive
      {% if pillar.cdh5.security.enable %}
      - cmd: hive_kinit
      {% endif %}

# This was chmodding the dir to 771 permissions, and it was breaking things
warehouse_dir_permissions:
  cmd:
    - run
    - name: 'hdfs dfs -chmod 1777 /user/{{pillar.cdh5.hive.user}}/warehouse'
    - user: hive
    - require:
      - cmd: create_warehouse_dir

scratch_dir_permissions:
  cmd:
    - run
    - name: 'hdfs dfs -chmod 1777 /user/{{pillar.cdh5.hive.user}}/tmp'
    - user: hive
    - require:
      - cmd: create_scratch_dir

hive-metastore:
  service:
    - running
    - require: 
      - pkg: hive
      - cmd: configure_metastore
      - cmd: warehouse_dir_permissions
      - cmd: scratch_dir_permissions
      - service: mysql-svc
      - file: /usr/lib/hive/lib/mysql-connector-java.jar
      - file: /etc/hive/conf/hive-site.xml
      - file: /mnt/tmp/
    - watch:
      - file: /etc/hive/conf/hive-site.xml

hive-server2:
  service:
    - running
    - require: 
      - service: hive-metastore
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hive_keytabs 
      {% endif %}
    - watch:
      - file: /etc/hive/conf/hive-site.xml

/mnt/tmp/:
  file:
    - directory
    - user: root
    - group: root
    - dir_mode: 777
    - recurse:
      - mode
