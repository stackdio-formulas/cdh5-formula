/etc/spark/conf/spark.key:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - contents_pillar: ssl:private_key

/etc/spark/conf/spark.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /etc/spark/conf/spark.key

/etc/spark/conf/ca.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:ca_certificate
    - require:
      - file: /etc/spark/conf/spark.key

/etc/spark/conf/chained.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /etc/spark/conf/spark.key

create-pkcs12:
  cmd.run:
    - user: root
    - name: openssl pkcs12 -export -in /etc/spark/conf/spark.crt -certfile /etc/spark/conf/chained.crt -inkey /etc/spark/conf/spark.key -out /etc/spark/conf/spark.pkcs12 -name {{ grains.id }} -password pass:spark123
    - require:
      - file: /etc/spark/conf/chained.crt
      - file: /etc/spark/conf/spark.crt
      - file: /etc/spark/conf/spark.key

create-truststore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importcert -keystore /etc/spark/conf/spark.truststore -storepass spark123 -file /etc/spark/conf/ca.crt -alias root-ca -noprompt
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/spark/conf/spark.truststore -storepass spark123 | grep root-ca
    - require:
      - file: /etc/spark/conf/ca.crt

create-keystore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /etc/spark/conf/spark.pkcs12 -srcstorepass spark123 -srcstoretype pkcs12 -destkeystore /etc/spark/conf/spark.keystore -deststorepass spark123
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/spark/conf/spark.keystore -storepass spark123 | grep {{ grains.id }}
    - require:
      - cmd: create-pkcs12

chown-keystore:
  cmd.run:
    - user: root
    - name: chown root:spark /etc/spark/conf/spark.keystore
    - require:
      - cmd: create-keystore

nginx:
  pkg.installed: []

/etc/nginx/conf.d:
  file.directory:
    - clean: true
    - require:
      - pkg: nginx

/etc/nginx/conf.d/spark.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://cdh5/spark/encryption/spark.conf
    - template: jinja
    - require:
      - file: /etc/nginx/conf.d

nginx-svc:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/conf.d
      - file: /etc/nginx/conf.d/spark.conf
