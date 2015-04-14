{% set oozie_data_dir = '/var/lib/oozie' %}

# 
# Install the Oozie package
#

include:
  - cdh5.repo
  - cdh5.landing_page
{% if salt['pillar.get']('cdh5:oozie:start_service', True) %}
  - cdh5.oozie.service
{% endif %}
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.oozie.security
{% endif %}

unzip:
  pkg:
    - installed

oozie:
  pkg:
    - installed
    - pkgs:
      - oozie
      - oozie-client
    - require:
      - module: cdh5_refresh_db

{% if salt['pillar.get']('cdh5:security:enable', False) %}
/etc/oozie/conf/oozie-site.xml:
  file:
    - managed
    - source: salt://cdh5/etc/oozie/conf/oozie-site.xml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: oozie

/etc/oozie/conf/oozie-env.sh:
  file:
    - managed
    - source: salt://cdh5/etc/oozie/conf/oozie-env.sh
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: oozie
{% endif %}

extjs:
  file:
    - managed
    - name: /srv/sync/cdh5/ext-2.2.zip
    - source: http://extjs.com/deploy/ext-2.2.zip
    - source_hash: md5=12c624674b3af9d2ce218b1245a3388f
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - require:
      - pkg: oozie
  cmd:
    - run
    - name: 'unzip -d {{ oozie_data_dir }} /srv/sync/cdh5/ext-2.2.zip &> /dev/null'
    - unless: 'test -d {{ oozie_data_dir }}/ext-*'
    - require:
      - file: /srv/sync/cdh5/ext-2.2.zip
      - pkg: unzip
      - pkg: oozie

/var/log/oozie:
  file:
    - directory
    - user: oozie
    - group: oozie
    - recurse:
      - user
      - group

/var/lib/oozie:
  file:
    - directory
    - user: oozie
    - group: oozie
    - recurse:
      - user
      - group

