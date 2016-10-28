/etc/oozie/conf/ca:
  file:
    - recurse
    - source: salt://cdh5/ca
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - context:
      conf_dir: /etc/oozie/conf

/etc/oozie/conf/ca/private/cakey.pem:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: cdh5:encryption:ca_key
    - require:
      - file: /etc/oozie/conf/ca

/etc/oozie/conf/ca/certs/cacert.pem:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: cdh5:encryption:ca_cert
    - require:
      - file: /etc/oozie/conf/ca

# Delete before re-creating to ensure idempotency
delete-truststore:
  cmd:
    - run
    - user: root
    - name: rm -f /etc/oozie/conf/oozie.truststore

create-truststore:
  cmd:
    - run
    - user: root
    - name: /usr/java/latest/bin/keytool -importcert -keystore /etc/oozie/conf/oozie.truststore -storepass oozie123 -file /etc/oozie/conf/ca/certs/cacert.pem -alias cdh5-ca -noprompt
    - require:
      - cmd: delete-truststore
      - file: /etc/oozie/conf/ca
      - file: /etc/oozie/conf/ca/private/cakey.pem
      - file: /etc/oozie/conf/ca/certs/cacert.pem

create-keystore:
  file:
    - copy
    - name: /etc/oozie/conf/oozie.keystore
    - source: /etc/oozie/conf/oozie.truststore
    - user: root
    - group: root
    - force: true
    - mode: 600
    - require:
      - cmd: create-truststore

create-key:
  cmd:
    - run
    - user: root
    - name: 'printf "CDH5 {{ grains.id }}\n\nCDH5\nUS\nUS\nUS\nyes\n" | /usr/java/latest/bin/keytool -genkey -alias {{ grains.id }} -keystore /etc/oozie/conf/oozie.keystore -storepass oozie123 -keyalg RSA -keysize 2048 -validity 8000 -ext san=dns:{{ grains.fqdn }}'
    - require:
      - file: create-keystore

create-csr:
  cmd:
    - run
    - user: root
    - name: '/usr/java/latest/bin/keytool -certreq -alias {{ grains.id }} -keystore /etc/oozie/conf/oozie.keystore -storepass oozie123 -file /etc/oozie/conf/oozie.csr -keyalg rsa -ext san=dns:{{ grains.fqdn }}'
    - require:
      - cmd: create-key

sign-csr:
  cmd:
    - run
    - user: root
    - name: 'printf "{{ pillar.cdh5.encryption.ca_key_pass }}\ny\ny\n" | openssl ca -in /etc/oozie/conf/oozie.csr -notext -out /etc/oozie/conf/oozie-signed.crt -config /etc/oozie/conf/ca/conf/caconfig.cnf -extensions v3_req'
    - require:
      - cmd: create-csr

import-signed-crt:
  cmd:
    - run
    - user: root
    - name: '/usr/java/latest/bin/keytool -importcert -keystore /etc/oozie/conf/oozie.keystore -storepass oozie123 -file /etc/oozie/conf/oozie-signed.crt -alias {{ grains.id }}'
    - require:
      - cmd: sign-csr

chown-keystore:
  cmd:
    - run
    - user: root
    - name: chown oozie:hadoop /etc/oozie/conf/oozie.keystore
    - require:
      - cmd: import-signed-crt

# Don't leave the CA lying around.  Must be a cmd instead of file.absent, as it causes a name collision otherwise.
remove-ca:
  cmd:
    - run
    - name: rm -rf /etc/oozie/conf/ca
    - require:
      - cmd: create-truststore
      - cmd: import-signed-crt
