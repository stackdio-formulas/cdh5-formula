include:
  - cdh5.repo
  - cdh5.impala.conf
{% if salt['pillar.get']('cdh5:impala:start_service', True) %}
  - cdh5.impala.state-store.service
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
      - impala-catalog
      - impala-state-store
      - impala-shell
      - cyrus-sasl-gssapi
    - require:
      - module: cdh5_refresh_db
