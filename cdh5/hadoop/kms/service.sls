

hadoop-kms-server-svc:
  service:
    - running
    - name: hadoop-kms-server
    - require:
      - pkg: hadoop-kms-server
      - file: /etc/hadoop-kms/conf
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_kms_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop-kms/conf
