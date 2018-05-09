cloudera-scm-agent-svc:
  service.running:
    - name: cloudera-scm-agent
    - enable: true
    - require:
      - pkg: scm-agent-packages
    - watch:
      - file: scm-agent-config
