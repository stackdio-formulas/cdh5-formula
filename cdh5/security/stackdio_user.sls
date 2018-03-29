
include:
  - krb5
  - cdh5.security

{% for user in pillar.__stackdio__.users %}
generate_keytab_{{ user.username }}:
  cmd:
    - script
    - source: salt://cdh5/security/generate_user_keytab.sh
    - template: jinja
    - user: root
    - group: root
    - env:
      - STACKDIO_USER: {{ user.username }}
    - cwd: /home/{{ user.username }}
    - unless: test -f /home/{{ user.username }}/{{ user.username }}.keytab
    - require:
      - module: load_admin_keytab
{% endfor %}
