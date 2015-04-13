{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
export KRB5_CONFIG={{ pillar.krb5.conf_file }}

cd /etc/hadoop/conf
rm -rf *.keytab
(
echo "addprinc -randkey HTTP/{{ grains.fqdn }}"
echo "addprinc -randkey hdfs/{{ grains.fqdn }}"
echo "addprinc -randkey mapred/{{ grains.fqdn }}"
echo "addprinc -randkey yarn/{{ grains.fqdn }}"
echo "xst -k hdfs-unmerged.keytab hdfs/{{ grains.fqdn }}"
echo "xst -k mapred-unmerged.keytab mapred/{{ grains.fqdn }}"
echo "xst -k yarn-unmerged.keytab yarn/{{ grains.fqdn }}"
echo "xst -k HTTP.keytab HTTP/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

(
echo "rkt hdfs-unmerged.keytab"
echo "rkt HTTP.keytab"
echo "wkt hdfs.keytab"
echo "clear"
echo "rkt mapred-unmerged.keytab"
echo "rkt HTTP.keytab"
echo "wkt mapred.keytab"
echo "clear"
echo "rkt yarn-unmerged.keytab"
echo "rkt HTTP.keytab"
echo "wkt yarn.keytab"
) | ktutil

rm -rf *-unmerged.keytab HTTP.keytab
id -u hdfs &> /dev/null && chown hdfs:hadoop hdfs.keytab
id -u mapred &> /dev/null && chown mapred:hadoop mapred.keytab
id -u yarn &> /dev/null && chown yarn:hadoop yarn.keytab
chmod 400 *.keytab
