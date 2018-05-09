/opt/cloudera/security/pki:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: true

/opt/cloudera/security/pki/ca.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - makedirs: true
    - contents_pillar: ssl:ca_certificate
    - require:
      - file: /opt/cloudera/security/pki

import-ca:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importcert -keystore /usr/java/latest/jre/lib/security/cacerts -storepass changeit -file /opt/cloudera/security/pki/ca.crt -alias dr-root-ca -noprompt
    - unless: /usr/java/latest/bin/keytool -list -keystore /usr/java/latest/jre/lib/security/cacerts -storepass changeit | grep dr-root-ca
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

/opt/cloudera/security/pki/server.key:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: ssl:private_key
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

/opt/cloudera/security/pki/server.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

/opt/cloudera/security/pki/{{ grains.fqdn }}-server.cert.pem:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:chained_certificate
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

create-pkcs12:
  cmd.run:
    - user: root
    - name: openssl pkcs12 -export -in /opt/cloudera/security/pki/server.crt -certfile /opt/cloudera/security/pki/{{ grains.fqdn }}-server.cert.pem -inkey /opt/cloudera/security/pki/server.key -out /opt/cloudera/security/pki/server.pkcs12 -name {{ grains.fqdn }}-server -password pass:manager
    - require:
      - file: /opt/cloudera/security/pki/{{ grains.fqdn }}-server.cert.pem
      - file: /opt/cloudera/security/pki/server.crt
      - file: /opt/cloudera/security/pki/server.key

create-keystore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /opt/cloudera/security/pki/server.pkcs12 -srcstorepass manager -srcstoretype pkcs12 -destkeystore /opt/cloudera/security/pki/{{ grains.fqdn }}-server.jks -deststorepass manager
    - unless: /usr/java/latest/bin/keytool -list -keystore /opt/cloudera/security/pki/{{ grains.fqdn }}-server.jks -storepass manager | grep {{ grains.fqdn }}-server | grep PrivateKeyEntry
    - require:
      - cmd: create-pkcs12

chmod-keystore:
  cmd.run:
    - user: root
    - name: chmod 400 /opt/cloudera/security/pki/{{ grains.fqdn }}-server.jks
    - require:
      - cmd: create-keystore

chown-keystore:
  cmd.run:
    - user: root
    - name: chown cloudera-scm:cloudera-scm /opt/cloudera/security/pki/{{ grains.fqdn }}-server.jks
    - require:
      - cmd: create-keystore
      - cmd: chmod-keystore
      - pkg: scm-server-packages
