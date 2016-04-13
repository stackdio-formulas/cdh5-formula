#
# Install the Oozie package
#

{% set oozie_host = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.oozie', 'grains.items', 'compound').values()[0]['fqdn'] %}

include:
  - cdh5.repo
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
{% endif %}

oozie-client:
  pkg:
    - installed
    - require:
      - module: cdh5_refresh_db

{% if salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.kms', 'grains.items', 'compound') %}
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
    - contents: export OOZIE_URL={{ oozie_url }}
