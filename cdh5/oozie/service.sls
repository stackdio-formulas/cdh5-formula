{% set oozie_data_dir = '/var/lib/oozie' %}
{% set nn_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.namenode and not G@roles:cdh5.hadoop.standby', 'grains.items', 'compound').values()[0]['fqdn'] %}
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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
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

{% if salt['pillar.get']('cdh5:security:enable', False) %}
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
{% endif %}

populate-oozie-sharelibs:
  cmd:
    - run
    {% if salt['pillar.get']('cdh5:security:enable', False) %}
    - name: '/usr/lib/oozie/bin/oozie-sharelib-kerberos.sh create -fs hdfs://{{nn_host}}:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz'
    - user: oozie
    {% else %}
    - name: 'oozie-setup sharelib create -fs hdfs://{{nn_host}}:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz'
    - user: root
    {% endif %}
    - unless: 'hdfs dfs -test -d /user/oozie/share'
    - require:
      - cmd: create-oozie-sharelibs

oozie-svc:
  service:
    - running
    - name: oozie
    - require:
      - pkg: oozie
      - cmd: extjs
      - cmd: ooziedb
      - cmd: populate-oozie-sharelibs
      - file: /var/log/oozie
      - file: /var/lib/oozie
    - watch:
      - cmd: ooziedb
      - cmd: populate-oozie-sharelibs
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - file: /etc/oozie/conf/oozie-site.xml
      - cmd: generate_oozie_keytabs
{% endif %}