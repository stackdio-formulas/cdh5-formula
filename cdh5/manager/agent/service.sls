cloudera-scm-agent-svc:
  service:
    - running
    - name: cloudera-scm-agent
    - require:
      - pkg: scm_agent_packages
