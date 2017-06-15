
generate_spark_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/spark/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/spark/conf
    - unless: test -f /etc/spark/conf/spark.keytab
    - require:
      - module: load_admin_keytab
