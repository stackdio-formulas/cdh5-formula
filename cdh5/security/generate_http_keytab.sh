{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

if [ -f HTTP.keytab ]; then
   exit 0
fi

export KRB5_CONFIG={{ pillar.krb5.conf_file }}

(
echo "addprinc -randkey HTTP/{{ grains.fqdn }}"
echo "xst -k HTTP.keytab HTTP/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown root:root HTTP.keytab
chmod 400 HTTP.keytab
