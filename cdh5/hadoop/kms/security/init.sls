
include:
  - krb5
  - cdh5.security

generate_hadoop_kms_keytabs:
  cmd.script:
    - source: salt://cdh5/hadoop/kms/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hadoop-kms/conf
    - unless: test -f /etc/hadoop-kms/conf/kms.keytab
    - require:
      - module: load_admin_keytab
      - cmd: generate_http_keytab
