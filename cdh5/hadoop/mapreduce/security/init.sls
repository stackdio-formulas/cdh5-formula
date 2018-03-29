
include:
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user

generate_hadoop_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/hadoop/mapreduce/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hadoop/conf
    - unless: test -f /etc/hadoop/conf/mapred.keytab
    - require:
      - module: load_admin_keytab
      - cmd: generate_http_keytab

