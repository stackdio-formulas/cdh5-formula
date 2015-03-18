{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
rm -rf *.keytab
(
echo "addprinc -randkey hive/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k hive.keytab hive/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown hive:hive hive.keytab
chmod 400 *.keytab
