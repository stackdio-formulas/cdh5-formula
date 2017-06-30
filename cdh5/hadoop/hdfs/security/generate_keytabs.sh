{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

(
echo "addprinc -randkey hdfs/{{ grains.fqdn }}"
echo "xst -k hdfs-unmerged.keytab hdfs/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt hdfs-unmerged.keytab"
echo "rkt /root/HTTP.keytab"
echo "wkt hdfs.keytab"
) | ktutil

rm -f hdfs-unmerged.keytab
chown hdfs:hadoop hdfs.keytab
chmod 400 hdfs.keytab
