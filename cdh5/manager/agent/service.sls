cloudera-scm-agent-svc:
  service:
    - running
    - name: cloudera-scm-agent
    - require:
      - file: scm_agent_config
