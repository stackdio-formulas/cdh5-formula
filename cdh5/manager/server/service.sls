cloudera-scm-server-db-svc:
  service.running:
    - name: cloudera-scm-server-db
    - enable: true
    - require:
      - pkg: scm-server-packages

cloudera-scm-server-svc:
  service.running:
    - name: cloudera-scm-server
    - enable: true
    - require:
      - service: cloudera-scm-server-db
