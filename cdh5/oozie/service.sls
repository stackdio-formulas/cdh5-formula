{% set oozie_data_dir = '/var/lib/oozie' %}

# 
# Start the Oozie service
#

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

oozie-sharelibs:        
  cmd:
    - run
    - name: 'hdfs dfs -mkdir -p /user/oozie/share/lib && hdfs dfs -chown -R oozie:oozie /user/oozie'
    - unless: 'hdfs dfs -test -d /user/oozie/share/lib'
    - user: hdfs
    - require:
      - service: oozie-svc

