/etc/hadoop/conf/ca:
  file:
    - recurse
    - source: salt://cdh5/ca
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - context:
      conf_dir: /etc/hadoop/conf

/etc/hadoop/conf/ca/private/cakey.pem:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: cdh5:encryption:ca_key
    - require:
      - file: /etc/hadoop/conf/ca

/etc/hadoop/conf/ca/certs/cacert.pem:
  file:
    - managed
    - user: root
    - group: root
    - mode: 400
    - makedirs: true
    - contents_pillar: cdh5:encryption:ca_cert
    - require:
      - file: /etc/hadoop/conf/ca

# Delete before re-creating to ensure idempotency
delete-truststore:
  cmd:
    - run
    - user: root
    - name: rm -f /etc/hadoop/conf/hadoop.truststore

create-truststore:
  cmd:
    - run
    - user: root
    - name: /usr/java/latest/bin/keytool -importcert -keystore /etc/hadoop/conf/hadoop.truststore -storepass hadoop -file /etc/hadoop/conf/ca/certs/cacert.pem -alias hadoop-ca -noprompt
    - require:
      - cmd: delete-truststore
      - file: /etc/hadoop/conf/ca
      - file: /etc/hadoop/conf/ca/private/cakey.pem
      - file: /etc/hadoop/conf/ca/certs/cacert.pem

{% if 'cdh5.hadoop.client' not in grains.roles %}

create-keystore:
  file:
    - copy
    - name: /etc/hadoop/conf/hadoop.keystore
    - source: /etc/hadoop/conf/hadoop.truststore
    - user: root
    - group: root
    - force: true
    - mode: 640
    - require:
      - cmd: create-truststore

create-key:
  cmd:
    - run
    - user: root
    - name: 'printf "CDH5 {{ grains.id }}\n\nCDH5\nUS\nUS\nUS\nyes\n" | /usr/java/latest/bin/keytool -genkey -alias {{ grains.id }} -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop -keyalg RSA -keysize 2048 -validity 8000 -ext san=dns:{{ grains.fqdn }}'
    - require:
      - file: create-keystore

create-csr:
  cmd:
    - run
    - user: root
    - name: '/usr/java/latest/bin/keytool -certreq -alias {{ grains.id }} -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop -file /etc/hadoop/conf/hadoop.csr -keyalg rsa -ext san=dns:{{ grains.fqdn }}'
    - require:
      - cmd: create-key

sign-csr:
  cmd:
    - run
    - user: root
    - name: 'printf "{{ pillar.cdh5.encryption.ca_key_pass }}\ny\ny\n" | openssl ca -in /etc/hadoop/conf/hadoop.csr -notext -out /etc/hadoop/conf/hadoop-signed.crt -config /etc/hadoop/conf/ca/conf/caconfig.cnf -extensions v3_req'
    - require:
      - cmd: create-csr

import-signed-crt:
  cmd:
    - run
    - user: root
    - name: '/usr/java/latest/bin/keytool -importcert -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop -file /etc/hadoop/conf/hadoop-signed.crt -alias {{ grains.id }}'
    - require:
      - cmd: sign-csr
    - require_in:
      - cmd: remove-ca

chown-keystore:
  cmd:
    - run
    - user: root
    - name: chown root:hadoop /etc/hadoop/conf/hadoop.keystore
    - require:
      - cmd: import-signed-crt

{% endif %}

# Don't leave the CA lying around.  Must be a cmd instead of file.absent, as it causes a name collision otherwise.
remove-ca:
  cmd:
    - run
    - name: rm -rf /etc/hadoop/conf/ca
    - require:
      - cmd: create-truststore

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
