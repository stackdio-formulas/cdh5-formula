

hadoop-kms-server-svc:
  service.running:
    - name: hadoop-kms-server
    - enable: true
    - require:
      - pkg: hadoop-kms-server
      - file: /etc/hadoop-kms/conf
      - cmd: hadoop-kms-server-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: replace-tomcat-conf
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_kms_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop-kms/conf
