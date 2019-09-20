#
# Start the ZooKeeper service
#

/etc/zookeeper/conf/zoo.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/zookeeper/conf/zoo.cfg
    - user: root
    - group: root
    - mode: 644
    - require: 
      - pkg: zookeeper

{% if pillar.cdh5.security.enable %}
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
    - require_in:
      - cmd: zookeeper-init

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
    - require_in:
      - cmd: zookeeper-init
{% endif %}

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
{% if pillar.cdh5.security.enable %}
      - cmd: generate_zookeeper_keytabs
{% endif %}

zookeeper-init:
  cmd:
    - run
    - name: 'service zookeeper-server init --force'
    - unless: 'ls {{pillar.cdh5.zookeeper.data_dir}}/version-*'
    - require:
      - cmd: zookeeper-init-script
      - file: zk_data_dir
      - file: /etc/zookeeper/conf/zoo.cfg

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

zookeeper-server-svc:
  service:
    - running
    - name: zookeeper-server
    - enable: true
    - require:
        - cmd: zookeeper-init
        - cmd: zookeeper-init-script
        - file: /etc/zookeeper/conf/zoo.cfg
        - file: /etc/zookeeper/conf/log4j.properties
        - file: myid
        {% if pillar.cdh5.security.enable %}
        - cmd: generate_zookeeper_keytabs
        {% endif %}
