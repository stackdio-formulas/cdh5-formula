mysql-svc:
  service:
    - running
    {% if grains['os_family'] == 'Debian' %}
    - name: mysql
    {% elif grains['os_family'] == 'RedHat' %}
    - name: mysqld
    {% endif %}
    - require:
      - pkg: mysql

configure_mysql:
  cmd:
    - script
    - template: jinja
    - source: salt://cdh5/sqoop/configure_mysql_sqoop.sh
    - unless: echo "select User, Host from mysql.user" | mysql -u root | grep {{ pillar.cdh5.sqoop.user }}
    - require:
      - pkg: sqoop2-server
      - service: mysql-svc

hdfs_dir:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs dfs -mkdir /user/sqoop2 && hdfs dfs -chown sqoop2:sqoop2 /user/sqoop2'
    - unless: 'hdfs dfs -test -d /user/sqoop2'
    - require:
      - pkg: sqoop2-server

sqoop2-server-svc:
  service:
    - running
    - name: sqoop2-server
    - require:
      - alternatives: sqoop2-tomcat-conf
      - cmd: hdfs_dir
      - file: mysql_jar
      - cmd: configure_mysql
