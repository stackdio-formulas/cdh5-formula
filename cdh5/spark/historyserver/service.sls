

history-dir:
  cmd:
    - run
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p /user/spark/applicationHistory && hdfs dfs -chown -R spark:spark /user/spark && hdfs dfs -chmod 1777 /user/spark/applicationHistory'
    - require:
      - pkg: spark-history-server


/etc/spark/conf/spark-defaults.conf:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-defaults.conf
    - template: jinja
    - require:
      - pkg: spark-history-server


spark-history-server-svc:
  service:
    - running
    - name: spark-history-server
    - require:
      - pkg: spark-history-server
      - cmd: history-dir
    - watch:
      - file: /etc/spark/conf/spark-defaults.conf
