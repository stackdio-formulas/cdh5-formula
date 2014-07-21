{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
(
echo "addprinc -randkey hbase/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k hbase.keytab hbase/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

chown hbase:hbase hbase.keytab
chmod 400 *.keytab
