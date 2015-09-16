create-keystore:
  cmd:
    - run
    - user: root
    - name: '$JAVA_HOME/bin/keytool -genkeypair -keystore /etc/hadoop/conf/hadoop.keystore -keyalg RSA -alias {{ grains.id }} -dname "CN={{ grains.fqdn }},O=Hadoop" -storepass hadoop -keypass hadoop'
    - unless: '$JAVA_HOME/bin/keytool -list -keystore /etc/hadoop/conf/hadoop.keystore -storepass hadoop | grep {{ grains.id }}

chown-keystore:
  cmd:
    - run
    - user: root
    - name: 'chown root:hadoop /etc/hadoop/conf/hadoop.keystore && chmod 440 /etc/hadoop/conf/hadoop.keystore'
    - require:
      - cmd: create-keystore
