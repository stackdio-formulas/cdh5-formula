# 
# Install the Hive package
#
include:
  - cdh5.repo
  - cdh5.hive.conf
{% if salt['pillar.get']('cdh5:hive:start_service', True) %}
  - cdh5.hive.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.hive.security
{% endif %}

extend:
  /etc/hive/conf/hive-site.xml:
    file:
      - require:
        - pkg: hive

hive:
  pkg:
    - installed
    - pkgs:
      - hive
      - hive-metastore
      - hive-server2
    - require:
      - pkg: mysql
      - module: cdh5_refresh_db

# @todo move this out to its own formula
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

/usr/lib/hive/lib/mysql-connector-java.jar:
  file:
    - symlink
    - target: /usr/share/java/mysql-connector-java.jar
    - require: 
      - pkg: mysql

{% if 'cdh5.sentry' in grains.roles %}
add_sentry_jars:
  cmd:
    - run
    - name: "find /usr/lib/sentry/lib -type f -name 'sentry*.jar' | xargs -n1 -Ifile ln -s file ."
    - unless: 'ls sentry*.jar &> /dev/null'
    - cwd: /usr/lib/hive/lib
    - require:
      - pkg: hive
{% endif %}
