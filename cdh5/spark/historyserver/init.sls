
include:
  - cdh5.repo
  - cdh5.landing_page
  {% if salt['pillar.get']('cdh5:spark:start_service', True) %}
  - cdh5.spark.historyserver.service
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.spark.security
  {% endif %}


spark-history-server:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
