/etc/hadoop/conf/hadoop.key:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - contents_pillar: ssl:private_key

/etc/hadoop/conf/hadoop.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /etc/hadoop/conf/hadoop.key

/etc/hadoop/conf/ca.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:ca_certificate
    - require:
      - file: /etc/hadoop/conf/hadoop.key

/etc/hadoop/conf/chained.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /etc/hadoop/conf/hadoop.key

create-pkcs12:
  cmd:
    - run
    - user: root
    - name: openssl pkcs12 -export -in /etc/hadoop/conf/hadoop.crt -certfile /etc/hadoop/conf/chained.crt -inkey /etc/hadoop/conf/hadoop.key -out /etc/hadoop/conf/hadoop.pkcs12 -name {{ grains.id }} -password pass:hadoop
    - require:
      - file: /etc/hadoop/conf/chained.crt
      - file: /etc/hadoop/conf/hadoop.crt
      - file: /etc/hadoop/conf/hadoop.key

create-keystore:
  cmd:
    - run
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /etc/hadoop/conf/hadoop.pkcs12 -srcstorepass hadoop -srcstoretype pkcs12 -destkeystore /etc/hadoop/conf/hadoop.keystore -deststorepass hadoop
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop | grep {{ grains.id }}
    - require:
      - cmd: create-pkcs12

chown-keystore:
  cmd:
    - run
    - user: root
    - name: chown root:hadoop /etc/hadoop/conf/hadoop.keystore
    - require:
      - cmd: create-keystore

nginx:
  pkg:
    - installed

/etc/nginx/conf.d:
  file:
    - directory
    - clean: true
    - require:
      - pkg: nginx

/etc/nginx/conf.d/hadoop.conf:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/hadoop/encryption/hadoop.conf
    - template: jinja
    - require:
      - file: /etc/nginx/conf.d

nginx-svc:
  service:
    - running
    - name: nginx
    - watch:
      - file: /etc/nginx/conf.d
      - file: /etc/nginx/conf.d/hadoop.conf
