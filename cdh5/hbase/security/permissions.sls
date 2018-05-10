{% if pillar.cdh5.security.enable %}

{% from 'krb5/settings.sls' import krb5 with context %}
{% set realm = krb5.realm %}

hbase-kinit:
  cmd:
    - run
    - name: kinit -kt /etc/hbase/conf/hbase.keytab hbase/{{ grains.fqdn }}@{{ realm }}
    - user: hbase
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'

grant-permissions:
  cmd:
    - run
    - name: echo "{% for user in pillar.__stackdio__.users %}grant '{{ user.username }}', 'RWXCA'; {% endfor %}grant 'oozie', 'RWXCA'" | hbase shell
    - user: hbase
    - require:
      - cmd: hbase-kinit

hbase-kdestroy:
  cmd:
    - run
    - name: kdestroy
    - user: hbase
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: grant-permissions
      - cmd: hbase-kinit

{% endif %}