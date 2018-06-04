/etc/oozie/conf/ca.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - makedirs: true
    - contents_pillar: ssl:ca_certificate

{% if 'cdh5.oozie' in grains.roles %}
/etc/oozie/conf/oozie.key:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: ssl:private_key
    - require:
      - file: /etc/oozie/conf/ca.crt

/etc/oozie/conf/oozie.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /etc/oozie/conf/ca.crt

/etc/oozie/conf/chained.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /etc/oozie/conf/ca.crt

create-pkcs12:
  cmd:
    - run
    - user: root
    - name: openssl pkcs12 -export -in /etc/oozie/conf/oozie.crt -certfile /etc/oozie/conf/chained.crt -inkey /etc/oozie/conf/oozie.key -out /etc/oozie/conf/oozie.pkcs12 -name {{ grains.id }} -password pass:oozie123
    - require:
      - file: /etc/oozie/conf/chained.crt
      - file: /etc/oozie/conf/oozie.crt
      - file: /etc/oozie/conf/oozie.key

create-keystore:
  cmd:
    - run
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /etc/oozie/conf/oozie.pkcs12 -srcstorepass oozie123 -srcstoretype pkcs12 -destkeystore /etc/oozie/conf/oozie.keystore -deststorepass oozie123
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/oozie/conf/oozie.keystore -storepass oozie123 | grep {{ grains.id }}
    - require:
      - cmd: create-pkcs12

chmod-keystore:
  cmd:
    - run
    - user: root
    - name: chmod 400 /etc/oozie/conf/oozie.keystore
    - require:
      - cmd: create-keystore

chown-keystore:
  cmd:
    - run
    - user: root
    - name: chown oozie:oozie /etc/oozie/conf/oozie.keystore
    - require:
      - cmd: create-keystore
      - cmd: chmod-keystore

{% endif %}