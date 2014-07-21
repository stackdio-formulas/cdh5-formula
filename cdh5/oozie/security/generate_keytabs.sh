{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
(
echo "addprinc -randkey oozie/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k oozie.keytab oozie/{{ grains.fqdn }}@{{ realm }} HTTP/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

chown oozie:oozie oozie.keytab
chmod 400 *.keytab
