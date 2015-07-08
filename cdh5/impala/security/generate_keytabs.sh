{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
export KRB5_CONFIG={{ pillar.krb5.conf_file }}
rm -rf impala.keytab
(
echo "addprinc -randkey impala/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k impala-unmerged.keytab impala/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt impala-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt impala.keytab"
) | ktutil

rm -rf impala-unmerged.keytab HTTP.keytab
chown impala:impala impala.keytab
chmod 400 *.keytab
