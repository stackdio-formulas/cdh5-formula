{% if pillar.cdh5.security.enable %}
generate_hadoop_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/hadoop/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hadoop/conf
    - unless: test -f /etc/hadoop/conf/yarn.keytab
    - require:
      - module: load_admin_keytab
      - cmd: generate_http_keytab
{% endif %}
