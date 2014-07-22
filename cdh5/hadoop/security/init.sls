{% if salt['pillar.get']('cdh5:security:enable', False) %}
generate_hadoop_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/hadoop/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/hadoop/conf
    - require:
      - module: load_admin_keytab
{% endif %}
