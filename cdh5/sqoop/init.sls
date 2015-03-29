
include:
  - cdh5.repo
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:sqoop:start_service', True) %}
  - cdh5.sqoop.service
  {% endif %}

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

sqoop2-tomcat-conf:
  alternatives:
    - set
    - user: root
    - name: sqoop2-tomcat-conf
    - path: /etc/sqoop2/tomcat-conf.dist
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
