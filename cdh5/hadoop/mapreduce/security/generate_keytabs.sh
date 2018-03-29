{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

(
echo "addprinc -randkey mapred/{{ grains.fqdn }}"
echo "xst -k mapred-unmerged.keytab mapred/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt mapred-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt mapred.keytab"
) | ktutil

rm -f mapred-unmerged.keytab
chown mapred:hadoop mapred.keytab
chmod 400 mapred.keytab