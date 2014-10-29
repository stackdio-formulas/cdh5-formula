{% if salt['pillar.get']('cdh5:security:enable', False) %}
include:
  - krb5
  - cdh5.security

generate_user_keytab:
  cmd:
    - script
    - source: salt://cdh5/security/generate_user_keytab.sh
    - template: jinja
    - user: root
    - group: root
    - cwd: /home/{{ pillar.__stackdio__.username }}
    - require:
      - module: load_admin_keytab
{% endif %}
