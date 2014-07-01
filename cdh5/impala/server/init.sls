include:
  - cdh5.repo
  - cdh5.impala.conf
{% if salt['pillar.get']('cdh5:impala:start_service', True) %}
  - cdh5.impala.server.service
{% endif %}

impala:
  pkg:
    - installed
    - pkgs:
      - impala
      - impala-server
      - impala-shell
    - require:
      - module: cdh5_refresh_db

