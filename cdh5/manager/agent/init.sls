include:
  - cdh5.manager.repo
  {% if salt['pillar.get']('cdh5:manager:agent:start_service', True) %}
  - cdh5.manager.agent.service
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.manager.agent.encryption
  {% endif %}

scm-agent-packages:
  pkg.installed:
    - pkgs:
      - cloudera-manager-agent
      - cloudera-manager-daemons
    - require:
      - module: cloudera-manager-repo-refresh

scm-agent-config:
  file.managed:
    - name: /etc/cloudera-scm-agent/config.ini
    - source: salt://cdh5/etc/cloudera-scm-agent/config.ini
    - template: jinja
    - require:
      - pkg: scm-agent-packages
