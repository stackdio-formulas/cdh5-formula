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

/opt/cloudera/security/pki/agent.key:
  file.managed:
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: ssl:private_key
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

/opt/cloudera/security/pki/agent.crt:
  file.managed:
    - user: root
    - group: root
    - mode: 444
    - contents_pillar: ssl:certificate
    - require:
      - file: /opt/cloudera/security/pki/ca.crt

/opt/cloudera/security/pki/{{ grains.fqdn }}-agent.cert.pem:
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
    - name: openssl pkcs12 -export -in /opt/cloudera/security/pki/agent.crt -certfile /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.cert.pem -inkey /opt/cloudera/security/pki/agent.key -out /opt/cloudera/security/pki/agent.pkcs12 -name {{ grains.fqdn }}-agent -password pass:manager
    - require:
      - file: /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.cert.pem
      - file: /opt/cloudera/security/pki/agent.crt
      - file: /opt/cloudera/security/pki/agent.key

create-keystore:
  cmd.run:
    - user: root
    - name: /usr/java/latest/bin/keytool -importkeystore -srckeystore /opt/cloudera/security/pki/agent.pkcs12 -srcstorepass manager -srcstoretype pkcs12 -destkeystore /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.jks -deststorepass manager
    - unless: /usr/java/latest/bin/keytool -list -keystore /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.jks -storepass manager | grep {{ grains.fqdn }}-agent | grep PrivateKeyEntry
    - require:
      - cmd: create-pkcs12

chmod-keystore:
  cmd.run:
    - user: root
    - name: chmod 444 /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.jks
    - require:
      - cmd: create-keystore

chown-keystore:
  cmd.run:
    - user: root
    - name: chown root:root /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.jks
    - require:
      - cmd: create-keystore
      - cmd: chmod-keystore

/opt/cloudera/security/pki/agent.jks:
  file.symlink:
    - target: /opt/cloudera/security/pki/{{ grains.fqdn }}-agent.jks
    - user: root
    - group: root
    - mode: 444
    - require:
      - cmd: chown-keystore
