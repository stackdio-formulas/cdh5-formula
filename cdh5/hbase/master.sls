include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.hbase.regionserver_hostnames
  - cdh5.zookeeper
  - cdh5.hbase.conf

extend:
  /etc/hbase/conf/hbase-site.xml:
    file:
      - require:
        - pkg: hbase-master
  /etc/hbase/conf/hbase-env.sh:
    file:
      - require:
        - pkg: hbase-master

hbase-init:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir /hbase && hadoop fs -chown hbase:hbase /hbase'
    - unless: 'hadoop fs -test -d /hbase'
    - require:
      - pkg: hadoop-client

hbase-master:
  pkg:
    - installed 
    - require:
      - cmd: hbase-init
      - service: zookeeper-server
      - file: append_regionservers_etc_hosts
  service:
    - running
    - require: 
      - pkg: hbase-master
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

