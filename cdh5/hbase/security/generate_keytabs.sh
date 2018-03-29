{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
export KRB5_CONFIG={{ pillar.krb5.conf_file }}
(
echo "addprinc -randkey hbase/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k hbase-unmerged.keytab hbase/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt hbase-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt hbase.keytab"
) | ktutil

rm -f hbase-unmerged.keytab
chown hbase:hbase hbase.keytab
chmod 400 hbase.keytab
