{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
(
echo "addprinc -randkey oozie/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k oozie-unmerged.keytab oozie/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k HTTP.keytab HTTP/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

(
echo "rkt oozie-unmerged.keytab"
echo "rkt HTTP.keytab"
echo "wkt oozie.keytab"

rm -rf oozie-unmerged.keytab
rm -rf HTTP.keytab
chown oozie:oozie oozie.keytab
chmod 400 *.keytab
