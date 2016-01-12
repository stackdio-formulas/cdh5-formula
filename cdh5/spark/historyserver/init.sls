
include:
  - cdh5.repo
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:spark:start_service', True) %}
  - cdh5.spark.historyserver.service
{% endif %}


spark-history-server:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db


/etc/spark/conf/spark-defaults.conf:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-defaults.conf
    - template: jinja
    - require:
      - pkg: spark-history-server

/etc/spark/conf/spark-env.sh:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-env.sh
    - template: jinja
    - require:
      - pkg: spark-history-server