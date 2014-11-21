{% if salt['pillar.get']('cdh5:security:enable', False) %}

generate_ticket:
  cmd:
    - run
    - name: kinit -kt /etc/hbase/conf/hbase.keytab hbase/{{ grains.fqdn }}@{{ realm }}
    - user: hbase

grant_permissions:
  cmd:
    - run
    - name: hbase shell < "grant '{{ pillar.__stackdio__.username }}', 'RWXCA'\ngrant 'oozie', 'RWXCA'"
    - user: hbase
    - require:
      - cmd: generate_keytab

{% endif %}
