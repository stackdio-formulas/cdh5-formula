
#
# Start the ZooKeeper service
#

include:
  - cdh5.repo

/etc/zookeeper/conf/zoo.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/zookeeper/conf/zoo.cfg
    - mode: 755
    - require: 
      - pkg: zookeeper
    
zookeeper-server-svc:
  service:
    - running
    - name: zookeeper-server
    - unless: service zookeeper-server status
    - require:
        - file: myid

myid:
  file:
    - managed
    - name: '{{pillar.cdh5.zookeeper.data_dir}}/myid'
    - template: jinja
    - user: zookeeper
    - group: zookeeper
    - mode: 755
    - source: salt://cdh5/etc/zookeeper/conf/myid
    - require:
        - cmd: zookeeper-init

zookeeper-init:
  cmd:
    - run
    - name: 'service zookeeper-server init'
    - unless: 'ls {{pillar.cdh5.zookeeper.data_dir}}/*'
    - require:
      - pkg: zookeeper-server

