cloudera-scm-server-db-svc:
  service:
    - running
    - name: cloudera-scm-server-db
    - require:
      - pkg: scm_server_packages

cloudera-scm-server-svc:
  service:
    - running
    - name: cloudera-scm-server
    - require:
      - service: cloudera-scm-server-db
