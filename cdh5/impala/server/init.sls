include:
  - cdh5.repo
  - cdh5.impala.conf
{% if salt['pillar.get']('cdh5:impala:start_service', True) %}
  - cdh5.impala.server.service
{% endif %}
{% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.impala.security
{% endif %}

impala-server-install:
  pkg:
    - installed
    - pkgs:
      - impala
      - impala-server
      - impala-shell
      - cyrus-sasl-gssapi
    - require:
      - module: cdh5_refresh_db
    - require_in:
      - file: /etc/default/impala
      - file: /etc/default/bigtop-utils
      - file: /etc/impala/conf/hive-site.xml
      - file: /etc/impala/conf/core-site.xml
      - file: /etc/impala/conf/hdfs-site.xml
      {% if 'cdh5.hbase.master' in grains['roles'] or 'cdh5.hbase.regionserver' in grains['roles'] %}
      - file: /etc/impala/conf/hbase-site.xml
      {% endif %}
