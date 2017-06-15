
hadoop-yarn-resourcemanager-svc:
  service:
    - running
    - name: hadoop-yarn-resourcemanager
    - enable: true
    - require:
      - pkg: hadoop-yarn-resourcemanager
    - watch:
      - file: /etc/hadoop/conf
