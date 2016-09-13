{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

if [ -f kms.keytab ]; then
   exit 0
fi

rm -rf *.keytab

cp /root/HTTP.keytab kms.keytab

chown kms:hadoop kms.keytab
chmod 400 kms.keytab
