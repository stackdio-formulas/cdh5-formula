{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
(
echo "addprinc -randkey HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey hdfs/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey mapred/{{ grains.fqdn }}@{{ realm }}"
echo "addprinc -randkey yarn/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k hdfs.keytab hdfs/{{ grains.fqdn }}@{{ realm }} HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k mapred.keytab mapred/{{ grains.fqdn }}@{{ realm }}  HTTP/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k yarn.keytab yarn/{{ grains.fqdn }}@{{ realm }}  HTTP/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

chown root:root HTTP.keytab
chown hdfs:hadoop hdfs.keytab
chown mapred:hadoop mapred.keytab
chown yarn:hadoop yarn.keytab
chmod 400 *.keytab
