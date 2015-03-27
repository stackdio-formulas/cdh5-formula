# 
# Start the Hue service
#

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

/etc/hue/conf/hue.ini:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hue/hue.ini
    - mode: 755
