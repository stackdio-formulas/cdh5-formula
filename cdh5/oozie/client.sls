#
# Install the Oozie package
#

include:
  - cdh5.repo
  - cdh5.hadoop.conf
{% if salt['pillar.get']('cdh5:security:enable', False) %}
  - krb5
  - cdh5.security
  - cdh5.oozie.security
{% endif %}

oozie-client:
  pkg:
    - installed
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
      - pkg: oozie-client

/etc/oozie/conf/oozie-env.sh:
  file:
    - managed
    - source: salt://cdh5/etc/oozie/conf/oozie-env.sh
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: oozie-client
{% endif %}

/etc/oozie/conf/hadoop-conf:
  file:
    - symlink
    - target: /etc/hadoop/conf
    - force: true
    - user: root
    - group: root
    - require:
      - file: /etc/hadoop/conf
