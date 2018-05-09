include:
  - cdh5.landing_page
  - cdh5.manager.repo
  {% if salt['pillar.get']('cdh5:manager:server:start_service', True) %}
  - cdh5.manager.server.service
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.manager.security
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.manager.server.encryption
  {% endif %}

scm-server-packages:
  pkg.installed:
    - pkgs:
      - cloudera-manager-server
      - cloudera-manager-daemons
      - cloudera-manager-server-db-2
    - require:
      - module: cloudera-manager-repo-refresh
