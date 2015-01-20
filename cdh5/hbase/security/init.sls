{% if salt['pillar.get']('cdh5:security:enable', False) %}
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

set_hbase_permissions:
  cmd:
    - script
    - source: salt://cdh5/hbase/security/set_permissions.sh
    - template: jinja
    - user: hbase
    - group: hbase
    - cwd: /etc/hbase/conf
    - require:
	  - module: generate_hbase_keytabs

{% endif %}
