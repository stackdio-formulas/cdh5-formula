
#
# Start the ZooKeeper service
#

include:
  - cdh5.repo

{% if grains['os_family'] == 'Debian' %}
extend:
  remove_policy_file:
    file:
      - require:
        - service: zookeeper-server-svc
{% endif %}

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
    - name: 'service zookeeper-server init --force'
    - unless: 'ls {{pillar.cdh5.zookeeper.data_dir}}/*'
    - require:
      - file: zk_data_dir

zk_data_dir:
  file:
    - directory
    - name: {{pillar.cdh5.zookeeper.data_dir}}
    - user: zookeeper
    - group: zookeeper
    - dir_mode: 755
    - makedirs: true
    - require:
      - pkg: zookeeper-server
