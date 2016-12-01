{% set packages = salt['grains.filter_by']({
   'Debian': {
      'mysql': 'mysql-server',
      'connector': 'libmysql-java'
   },
   'RedHat': salt['grains.filter_by']({
      '6': {
         'mysql': 'mysql-server',
         'connector': 'mysql-connector-java'
      },
      '7': {
         'mysql': 'mariadb-server',
         'connector': 'mysql-connector-java'
      }
   }, 'osmajorrelease')
}) %}

#
# Install the Hive package
#
include:
  - cdh5.repo
  - cdh5.hive.conf
{% if salt['pillar.get']('cdh5:hive:start_service', True) %}
  - cdh5.hive.service
{% endif %}
{% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.hive.security
{% endif %}

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
    - require_in:
      - file: /etc/hive/conf/hive-site.xml

# @todo move this out to its own formula
mysql:
  pkg:
    - installed
    - pkgs:
      - {{ packages.mysql }}
      - {{ packages.connector }}

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

add_hive_jars_to_sentry:
  cmd:
    - run
    - name: "find /usr/lib/hive/lib -type f -name 'hive*.jar' | xargs -n1 -Ifile ln -s file ."
    - unless: 'ls hive*.jar &> /dev/null'
    - cwd: /usr/lib/sentry/lib
    - require:
      - pkg: hive
{% endif %}
