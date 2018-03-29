{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

(
echo "addprinc -randkey yarn/{{ grains.fqdn }}"
echo "xst -k yarn-unmerged.keytab yarn/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt yarn-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt yarn.keytab"
) | ktutil

rm -f yarn-unmerged.keytab
chown yarn:hadoop yarn.keytab
chmod 400 yarn.keytab
