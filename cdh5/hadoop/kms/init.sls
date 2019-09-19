include:
  - cdh5.repo
  - cdh5.hadoop.kms.conf
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:kms:start_service', True) %}
  - cdh5.hadoop.kms.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.kms.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.kms.security
  {% endif %}

hadoop-kms-server:
  pkg.installed:
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop-kms/conf
      {% if pillar.cdh5.encryption.enable %}
      - file: /etc/hadoop-kms/conf/kms.key
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_kms_keytabs
      {% endif %}

hadoop-kms-server-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/hadoop-kms-server"
    - require:
      - pkg: hadoop-kms-server


{% if pillar.cdh5.encryption.enable %}
replace-tomcat-conf:
  cmd.run:
    - user: root
    - name: alternatives --set hadoop-kms-tomcat-conf /etc/hadoop-kms/tomcat-conf.https
    - require:
      - pkg: hadoop-kms-server
{% endif %}
