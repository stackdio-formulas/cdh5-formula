{% if pillar.cdh5.security.enable %}
generate_impala_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/impala/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/impala/conf
    - require:
      - module: load_admin_keytab
      - cmd: generate_http_keytab
{% endif %}
