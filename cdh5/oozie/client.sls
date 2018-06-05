#
# Install the Oozie package
#

{% set oozie_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.oozie', 'grains.items', 'compound').values()[0]['fqdn'] %}

include:
  - cdh5.repo
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.oozie.encryption
  {% endif %}

oozie-client:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db
    {% if pillar.cdh5.encryption.enable %}
    - require_in:
      - file: /etc/oozie/conf/ca.crt
    {% endif %}

{% if pillar.cdh5.encryption.enable %}
  {% set oozie_url = 'https://' ~ oozie_host ~ ':11443/oozie' %}
{% else %}
  {% set oozie_url = 'http://' ~ oozie_host ~ ':11000/oozie' %}
{% endif %}

/etc/profile.d/oozie.sh:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - contents:
      - export OOZIE_URL={{ oozie_url }}
      {% if pillar.cdh5.security.enable %}
      - export OOZIE_CLIENT_OPTS="-Djava.security.krb5.conf={{ pillar.krb5.conf_file }}"
      {% endif %}
