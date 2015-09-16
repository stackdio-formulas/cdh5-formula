/root/server.crt:
  file:
    - managed
    - user: root
    - group: root
    - mode: 664
    - contents: '{{ pillar.cdh5.encryption.certificate }}'

/root/server.key:
  file:
    - managed
    - user: root
    - group: root
    - mode: 664
    - contents: '{{ pillar.cdh5.encryption.private_key }}'

convert-to-jks:
  cmd:
    - run
    - user: root
    - name: openssl pkcs12 -export -name {{ grains.id }} -in /root/server.crt -inkey /root/server.key -out /etc/hadoop/conf/hadoop.pkcs12
    - unless: '$JAVA_HOME/bin/keytool -list -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop | grep {{ grains.id }}'
    - require:
      - file: /root/server.crt
      - file: /root/server.key

create-keystore:
  cmd:
    - run
    - user: root
    - name: '$JAVA_HOME/bin/keytool -importkeystore -destkeystore /etc/hadoop/conf/hadoop.keystore -srckeystore /etc/hadoop/conf/hadoop.pkcs12 -srcstoretype pkcs12 -alias {{ grains.id }} -storepass hadoop -keypass hadoop'
    - unless: '$JAVA_HOME/bin/keytool -list -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop | grep {{ grains.id }}'
    - require:
      - cmd: convert-to-jks

chown-keystore:
  cmd:
    - run
    - user: root
    - name: 'chown root:hadoop /etc/hadoop/conf/hadoop.keystore && chmod 440 /etc/hadoop/conf/hadoop.keystore'
    - require:
      - cmd: create-keystore
