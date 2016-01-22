{% if salt['pillar.get']('cdh5:security:enable', False) %}
include:
  - krb5
  - cdh5.security

{% for user in pillar.__stackdio__.users %}
generate_{{ user.username }}_keytab:
  cmd:
    - script
    - source: salt://cdh5/security/generate_user_keytab.sh
    - template: jinja
    - user: root
    - group: root
    - env:
      - STACKDIO_USER: {{ user.username }}
    - cwd: /home/{{ user.username }}
    - require:
      - module: load_admin_keytab
{% endfor %}
{% endif %}
