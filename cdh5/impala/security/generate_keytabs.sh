{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
rm -rf impala.keytab
(
echo "addprinc -randkey impala/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k impala.keytab impala/{{ grains.fqdn }}@{{ realm }} HTTP/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

chown impala:impala impala.keytab
chmod 400 *.keytab
