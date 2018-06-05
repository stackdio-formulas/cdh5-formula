/etc/hbase/conf/hbase.key:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - contents_pillar: ssl:private_key

/etc/hbase/conf/hbase.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /etc/hbase/conf/hbase.key

/etc/hbase/conf/ca.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:ca_certificate
    - require:
      - file: /etc/hbase/conf/hbase.key

/etc/hbase/conf/chained.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /etc/hbase/conf/hbase.key

create-hbase-pkcs12:
  cmd.run:
    - user: root
    - name: openssl pkcs12 -export -in /etc/hbase/conf/hbase.crt -certfile /etc/hbase/conf/chained.crt -inkey /etc/hbase/conf/hbase.key -out /etc/hbase/conf/hbase.pkcs12 -name {{ grains.id }} -password pass:hbase123
    - require:
      - file: /etc/hbase/conf/chained.crt
      - file: /etc/hbase/conf/hbase.crt
      - file: /etc/hbase/conf/hbase.key

create-hbase-keystore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /etc/hbase/conf/hbase.pkcs12 -srcstorepass hbase123 -srcstoretype pkcs12 -destkeystore /etc/hbase/conf/hbase.keystore -deststorepass hbase123
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/hbase/conf/hbase.keystore -storepass hbase123 | grep PrivateKeyEntry | grep {{ grains.id }}
    - require:
      - cmd: create-hbase-pkcs12

chown-hbase-keystore:
  cmd.run:
    - user: root
    - name: chown root:hbase /etc/hbase/conf/hbase.keystore
    - require:
      - cmd: create-hbase-keystore
