sqoop_installed:
  pkg.installed:
    - sqoop2-server


sqoop2-tomcat-conf:
  alternatives.set_:
    - name: sqoop2-tomcat-conf
    - path: /etc/sqoop2/tomcat-conf.dist
    - require:
      - cdh5.sqoop: installed


hdfs_dir:
  hadoop.dfs:
    - command: 'mkdir'
    - args:
      - '/user/sqoop2'
    - require:
      - cdh5.sqoop: installed


hdfs_permissions:
  hadoop.dfs:
    - command: 'chown'
    - args:
      - 'sqoop2'
      - '/user/sqoop2'
    - require:
      - cdh5.sqoop: hdfs_dir


mysql_jar:
  file.copy:
    - name: /var/lib/sqoop2/mysql-connector-java.jar
    - source: /usr/share/java/mysql-connector-java.jar
    - makedirs: True
    - require:
      - cdh5.sqoop: installed


mysql_user:
  mysql.user_create:
    - user: {% salt[pillar.get]('cdh5:sqoop:user', 'sqoop') %}
    - host: "{{ grains.stack.namespace }}-%"
    - password: {% salt[pillar.get]('cdh5:sqoop:password', '1234') %}
    - require:
      - cdh5.sqoop: mysql_jar


mysql_permissions:
  mysql.grant_add:
    - grant: "*"
    - database: "*"
    - user: {% salt[pillar.get]('cdh5:sqoop:user', 'sqoop') %}
    - host: "{{ grains.stack.namespace }}-%"
    - require:
      - cdh5.sqoop: mysql_user


sqoop2-server:
  service.running:
    - order: last
