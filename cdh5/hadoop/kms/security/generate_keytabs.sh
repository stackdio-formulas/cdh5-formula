{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

(
echo "addprinc -randkey kms/{{ grains.fqdn }}"
echo "xst -k kms-unmerged.keytab kms/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt kms-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt kms.keytab"
) | ktutil

rm -f kms-unmerged.keytab
chown kms:hadoop kms.keytab
chmod 400 kms.keytab
