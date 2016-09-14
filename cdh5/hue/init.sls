# 
# Install the Hue package
#
include:
  - cdh5.repo
  - cdh5.hadoop.client
  - cdh5.landing_page
  - cdh5.hue.plugins
{% if salt['pillar.get']('cdh5:hue:start_service', True) %}
  - cdh5.hue.service
{% endif %}
{% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.hue.security
{% endif %}

hue:
  pkg:
    - installed
    - pkgs:
      - hue
      - hue-server
      - hue-plugins
    - require:
      - module: cdh5_refresh_db

/mnt/tmp/hadoop:
  file:
    - directory
    - makedirs: true
    - mode: 777
