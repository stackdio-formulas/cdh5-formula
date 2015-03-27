sqoop2-server:
  pkg:
    - installed

# Add this here too so sqoop doesn't depend on hive
mysql:
  pkg:
    - installed
    - pkgs:
      - mysql-server
      {% if grains['os_family'] == 'Debian' %}
      - libmysql-java
      {% elif grains['os_family'] == 'RedHat' %}
      - mysql-connector-java
      {% endif %}

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

sqoop2-tomcat-conf:
  alternatives:
    - set
    - user: root
    - name: sqoop2-tomcat-conf
    - path: /etc/sqoop2/tomcat-conf.dist
    - require:
      - pkg: sqoop2-server

hdfs_dir:
  cmd:
    - run
    - user: hdfs
    - name: 'hdfs dfs -mkdir /user/sqoop2 && hdfs dfs -chown sqoop2:sqoop2 /user/sqoop2'
    - unlesee: 'hdfs dfs -test -d /user/sqoop2'
    - require:
      - pkg: sqoop2-server

mysql_jar:
  file:
    - copy
    - name: /var/lib/sqoop2/mysql-connector-java.jar
    - source: /usr/share/java/mysql-connector-java.jar
    - makedirs: True
    - require:
      - pkg: mysql
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
