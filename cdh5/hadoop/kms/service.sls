

hadoop-kms-server-svc:
  service:
    - running
    - name: hadoop-kms-server
    - require:
      - pkg: hadoop-kms-server
      - file: /etc/hadoop-kms/conf
      {% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hadoop_kms_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop-kms/conf
