{% if pillar.cdh5.security.enable %}
generate_hbase_keytabs:
  cmd:
    - script
    - source: salt://cdh5/hbase/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hbase/conf
    - require:
      - module: load_admin_keytab
{% endif %}
