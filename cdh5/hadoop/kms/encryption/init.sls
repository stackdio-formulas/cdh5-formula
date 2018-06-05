/etc/hadoop-kms/conf/kms.key:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - contents_pillar: ssl:private_key

/etc/hadoop-kms/conf/kms.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /etc/hadoop-kms/conf/kms.key

/etc/hadoop-kms/conf/ca.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:ca_certificate
    - require:
      - file: /etc/hadoop-kms/conf/kms.key

/etc/hadoop-kms/conf/chained.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /etc/hadoop-kms/conf/kms.key

create-pkcs12:
  cmd.run:
    - user: root
    - name: openssl pkcs12 -export -in /etc/hadoop-kms/conf/kms.crt -certfile /etc/hadoop-kms/conf/chained.crt -inkey /etc/hadoop-kms/conf/kms.key -out /etc/hadoop-kms/conf/kms.pkcs12 -name {{ grains.id }} -password pass:hadoopkms
    - require:
      - file: /etc/hadoop-kms/conf/chained.crt
      - file: /etc/hadoop-kms/conf/kms.crt
      - file: /etc/hadoop-kms/conf/kms.key

create-keystore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /etc/hadoop-kms/conf/kms.pkcs12 -srcstorepass hadoopkms -srcstoretype pkcs12 -destkeystore /etc/hadoop-kms/conf/kms.keystore -deststorepass hadoopkms
    - unless: /usr/java/latest/bin/keytool -list -keystore /etc/hadoop-kms/conf/kms.keystore -storepass hadoopkms | grep {{ grains.id }}
    - require:
      - cmd: create-pkcs12

chown-keystore:
  cmd.run:
    - user: root
    - name: chown root:kms /etc/hadoop-kms/conf/kms.keystore
    - require:
      - cmd: create-keystore
