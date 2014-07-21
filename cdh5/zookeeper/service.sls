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

{% if salt['pillar.get']('cdh5:security:enable', False) %}
/etc/zookeeper/conf/jaas.conf:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/zookeeper/conf/jaas.conf
    - user: root
    - group: root
    - mode: 644
    - require: 
      - pkg: zookeeper
      - file: /etc/zookeeper/conf/zoo.cfg

/etc/zookeeper/conf/java.env:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/zookeeper/conf/java.env
    - user: root
    - group: root
    - mode: 644
    - require: 
      - pkg: zookeeper
      - file: /etc/zookeeper/conf/zoo.cfg
{% endif %}
    
zookeeper-server-svc:
  service:
    - running
    - name: zookeeper-server
    - unless: service zookeeper-server status
    - require:
        - cmd: zookeeper-init
        - file: /etc/zookeeper/conf/zoo.cfg
        - file: /etc/zookeeper/conf/log4j.properties
{% if salt['pillar.get']('cdh5:security:enable', False) %}
        - cmd: generate_zookeeper_keytabs
{% endif %}

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
      - file: zk_data_dir

zookeeper-init:
  cmd:
    - run
    - name: 'service zookeeper-server init --force'
    - unless: 'ls {{pillar.cdh5.zookeeper.data_dir}}/version-*'
    - require:
      - file: myid

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
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_zookeeper_keytabs
{% endif %}
