{% if salt['pillar.get']('cdh5:security:enable', False) %}
generate_zookeeper_keytabs:
  cmd:
    - script 
    - source: salt://cdh5/zookeeper/security/generate_keytabs.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /etc/zookeeper/conf
    - require:
      - module: load_admin_keytab
{% endif %}
