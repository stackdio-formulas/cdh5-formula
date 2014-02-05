include:
  - cdh5.repo

zookeeper:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db

zookeeper-server:
  pkg:
    - installed
    - require:
      - pkg: zookeeper
  service:
    - running
    - require:
      - cmd: zookeeper-init

zookeeper-init:
  cmd:
    - run
    - name: 'service zookeeper-server init'
    - unless: 'ls /var/lib/zookeeper/*'
    - require:
      - pkg: zookeeper-server
