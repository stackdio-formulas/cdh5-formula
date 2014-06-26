
# 
# Start the HBase master service
#

include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.hbase.regionserver.hostnames
  - cdh5.zookeeper
  - cdh5.hbase.conf

hbase-init:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hadoop fs -mkdir /hbase && hadoop fs -chown hbase:hbase /hbase'
    - unless: 'hadoop fs -test -d /hbase'
    - require:
      - pkg: hadoop-client

hbase-master-svc:
  service:
    - running
    - name: hbase-master
    - require: 
      - pkg: hbase-master
      - cmd: hbase-init
      - service: zookeeper-server
      - file: append_regionservers_etc_hosts
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh
    - watch:
      - file: /etc/hbase/conf/hbase-site.xml
      - file: /etc/hbase/conf/hbase-env.sh

hbase-thrift-svc:
  cmd:
    - run
    - user: hbase
    - group: hbase
    - name: '/usr/lib/hbase/bin/hbase-daemon.sh start thrift'
    - unless: 'netstat -an | grep 9090'

