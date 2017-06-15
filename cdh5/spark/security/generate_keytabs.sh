{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

cd /etc/spark/conf
rm -rf *.keytab
(
echo "addprinc -randkey spark/{{ grains.fqdn }}"
echo "xst -k spark.keytab spark/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown spark:hadoop spark.keytab
chmod 400 *.keytab
