include:
  - krb5
  - cdh5.security

generate_hbase_keytab:
  cmd:
    - script
    - source: salt://cdh5/hbase/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hbase/conf
    - unless: test -f /etc/hbase/conf/hbase.keytab
    - require:
      - module: load_admin_keytab
