{% if pillar.cdh5.security.enable %}
generate_hive_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/hive/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hive/conf
    - require:
      - module: load_admin_keytab
{% endif %}
