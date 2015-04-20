# 
# Start the Hue service
#

/etc/hue/conf/hue.ini:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hue/hue.ini
    - mode: 755
    - require:
      - pkg: hue

{% if salt['pillar.get']('cdh5:security:enable', False) %}
/etc/init.d/hue:
  file:
    - replace
    - pattern: 'USER=hue'
    - repl: 'USER=hue\nexport KRB5_CONFIG={{ pillar.krb5.conf_file }}'
    - unless: cat /etc/init.d/hue | grep KRB5_CONFIG
    - require:
      - pkg: hue
    - require_in:
      - service: hue-svc
    - watch_in:
      - service: hue-svc
{% endif %}

hue-svc:
  service:
    - running
    - name: hue
    - require:
      - pkg: hue
      - file: /mnt/tmp/hadoop
      - file: /etc/hue/conf/hue.ini
{% if salt['pillar.get']('cdh5:security:enable', False) %}
      - cmd: generate_hue_keytabs 
{% endif %}
    - watch:
      - file: /etc/hue/conf/hue.ini
