{% set oozie_data_dir = '/var/lib/oozie' %}
{% set nn_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.hdfs.namenode', 'grains.items', 'compound').values()[0]['fqdn'] %}
# 
# Start the Oozie service
#

ooziedb:
  cmd:
    - run
    - name: '/usr/lib/oozie/bin/ooziedb.sh create -run'
    - unless: 'test -d {{ oozie_data_dir }}/oozie-db'
    - user: oozie
    - require:
      - pkg: oozie
      - cmd: extjs
      {% if pillar.cdh5.security.enable %}
      - file: /etc/oozie/conf/oozie-site.xml
      - file: /etc/oozie/conf/oozie-env.sh
      - cmd: generate_oozie_keytabs
      {% endif %}

create-oozie-sharelibs:        
  cmd:
    - run
    - name: 'hdfs dfs -mkdir /user/oozie && hdfs dfs -chown -R oozie:oozie /user/oozie'
    - unless: 'hdfs dfs -test -d /user/oozie'
    - user: hdfs
    - require:
      - cmd: ooziedb

{% if pillar.cdh5.security.enable %}
create_sharelib_script:
  file:
    - managed
    - name: /usr/lib/oozie/bin/oozie-sharelib-kerberos.sh
    - source: salt://cdh5/oozie/create_sharelibs.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require_in:
      - cmd: populate-oozie-sharelibs

hdfs_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require_in:
      - cmd: create-oozie-sharelibs

hdfs_kdestroy:
  cmd:
    - run
    - name: kdestroy
    - user: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hdfs_kinit
      - cmd: create-oozie-sharelibs
    - require_in:
      - service: oozie-svc

oozie_kinit:
  cmd:
    - run
    - name: 'kinit -kt /etc/oozie/conf/oozie.keytab oozie/{{ grains.fqdn }}'
    - user: oozie
    - group: oozie
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - pkg: oozie
    - require_in:
      - cmd: populate-oozie-sharelibs

oozie_kdestroy:
  cmd:
    - run
    - name: kdestroy
    - user: oozie
    - group: oozie
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - pkg: oozie
      - cmd: oozie_kinit
      - cmd: populate-oozie-sharelibs
    - require_in:
      - service: oozie-svc

{% endif %}

{% if (pillar.cdh5.version.split('.')[1] | int) >= 4 %}
{% set share = 'oozie-sharelib-yarn' %}
{% else %}
{% set share = 'oozie-sharelib-yarn.tar.gz' %}
{% endif %}

populate-oozie-sharelibs:
  cmd:
    - run
    {% if pillar.cdh5.security.enable %}
    - name: '/usr/lib/oozie/bin/oozie-sharelib-kerberos.sh create -fs hdfs://{{nn_host}}:8020 -locallib /usr/lib/oozie/{{ share }}'
    - user: oozie
    {% else %}
    - name: 'oozie-setup sharelib create -fs hdfs://{{nn_host}}:8020 -locallib /usr/lib/oozie/{{ share }}'
    - user: root
    {% endif %}
    - unless: 'hdfs dfs -test -d /user/oozie/share'
    - require:
      - cmd: create-oozie-sharelibs

oozie-svc:
  service:
    - running
    - name: oozie
    - enable: true
    - require:
      - pkg: oozie
      - cmd: extjs
      - cmd: ooziedb
      - cmd: populate-oozie-sharelibs
      - file: /var/log/oozie
      - file: /var/lib/oozie
      - cmd: oozie-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
    - watch:
      - cmd: ooziedb
      - cmd: populate-oozie-sharelibs
      {% if pillar.cdh5.security.enable %}
      - file: /etc/oozie/conf/oozie-site.xml
      - cmd: generate_oozie_keytabs
      {% endif %}