include:
  - cdh5.manager.repo
  {% if salt['pillar.get']('cdh5:manager:server:start_service', True) %}
  - cdh5.manager.server.service
  {% endif %}

scm_server_packages:
  pkg:
    - installed
    - pkgs:
      - cloudera-manager-server
      - cloudera-manager-daemons
      - cloudera-manager-server-db-2
    - require:
      - module: cloudera_manager_repo_refresh
