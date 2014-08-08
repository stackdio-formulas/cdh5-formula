include:
  - cdh5.manager.repo
  {% if salt['pillar.get']('cdh5:manager:agent:start_service', True) %}
  - cdh5.manager.agent.service
  {% endif %}

scm_agent_packages:
  pkg:
    - installed
    - pkgs:
      - cloudera-manager-agent
      - cloudera-manager-daemons
    - require:
      - module: cloudera_manager_repo_refresh

scm_agent_config:
  file:
    - managed
    - name: /etc/cloudera-scm-agent/config.ini
    - source: salt://cdh5/etc/cloudera-scm-agent/config.ini
    - template: jinja
    - require:
      - pkg: scm_agent_packages
