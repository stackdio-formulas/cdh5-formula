include:
  - cdh5.repo
  - cdh5.impala.conf
{% if salt['pillar.get']('cdh5:impala:start_service', True) %}
  - cdh5.impala.server.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.impala.security
{% endif %}

impala:
  pkg:
    - installed
    - pkgs:
      - impala
      - impala-server
      - impala-shell
      - cyrus-sasl-gssapi
    - require:
      - module: cdh5_refresh_db
