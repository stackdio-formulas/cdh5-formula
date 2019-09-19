
include:
  - cdh5.repo
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:spark:start_service', True) %}
  - cdh5.spark.historyserver.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.spark.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.spark.security
  {% endif %}


spark-history-server:
  pkg.installed:
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    {% if pillar.cdh5.encryption.enable or pillar.cdh5.security.enable %}
    - require_in:
      {% if pillar.cdh5.encryption.enable %}
      - file: /etc/spark/conf/spark.key
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_spark_keytabs
      {% endif %}
    {% endif %}

spark-history-server-init-script:
  cmd.run:
    - name: "sed -i 's/su /runuser /g' /etc/init.d/spark-history-server"
    - require:
      - pkg: spark-history-server
