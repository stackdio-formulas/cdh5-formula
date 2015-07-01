

hadoop-kms-server-svc:
  service:
    - running
    - name: hadoop-kms-server
    - require:
      - pkg: hadoop-kms-server
