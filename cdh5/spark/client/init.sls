
include:
  - cdh5.repo
  - cdh5.landing_page

spark-core:
  pkg.installed:
    - require:
      - module: cdh5_refresh_db

/etc/spark/conf/spark-defaults.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/etc/spark/spark-defaults.conf
    - template: jinja
    - require:
      - pkg: spark-core

/etc/spark/conf/spark-env.sh:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://cdh5/etc/spark/spark-env.sh
    - template: jinja
    - require:
      - pkg: spark-core
