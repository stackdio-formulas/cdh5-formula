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
      - file: /etc/hue/hue.ini

/etc/hue/hue.ini:
  file:
    - managed
    - template: jinja
    - source: salt://cdh5/etc/hue/hue.ini
    - mode: 755



