
hadoop-yarn-resourcemanager-svc:
  service:
    - running
    - name: hadoop-yarn-resourcemanager
    - enable: true
    - require:
      - pkg: hadoop-yarn-resourcemanager
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf
