{% set oozie_data_dir = '/var/lib/oozie' %}

# 
# Start the Oozie service
#

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: oozie-svc
{% endif %}

oozie-svc:
  service:
    - running
    - name: oozie
    - require:
      - pkg: oozie
      - cmd: extjs
      - cmd: ooziedb
      - file: /var/log/oozie
      - file: /var/lib/oozie

ooziedb:
  cmd:
    - run
    - name: '/usr/lib/oozie/bin/ooziedb.sh create -run'
    - unless: 'test -d {{ oozie_data_dir }}/oozie-db'
    - require:
      - pkg: oozie
      - cmd: extjs

create-oozie-sharelibs:        
  cmd:
    - run
    - name: 'hdfs dfs -mkdir /user/oozie && hdfs dfs -chown -R oozie:oozie /user/oozie'
    - unless: 'hdfs dfs -test -d /user/oozie'
    - user: hdfs
    - require:
      - service: oozie-svc

unpack-oozie-sharelibs:
  cmd:
    - run
    - name: 'mkdir /tmp/ooziesharelib && cd /tmp/ooziesharelib && tar xzf /usr/lib/oozie/oozie-sharelib-yarn.tar.gz'
    - require:
      - cmd: create-oozie-sharelibs

populate-oozie-sharelibs:
  cmd:
    - run
    - name: 'cd /tmp/ooziesharelib && hdfs dfs -put share /user/oozie/share'
    - unless: 'hdfs dfs -test -d /user/oozie/share'
    - user: oozie
    - require:
      - cmd: unpack-oozie-sharelibs

remove-oozie-sharelibs-tmp:
  cmd:
    - run
    - name: 'rm -rf /tmp/ooziesharelib'
    - require:
      - cmd: populate-oozie-sharelibs
