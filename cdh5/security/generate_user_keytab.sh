{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

if [ -f ${STACKDIO_USER}.keytab ]; then
   exit 0
fi

export KRB5_CONFIG={{ pillar.krb5.conf_file }}
(
echo "addprinc -randkey ${STACKDIO_USER}/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k ${STACKDIO_USER}.keytab ${STACKDIO_USER}/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown ${STACKDIO_USER}:${STACKDIO_USER} ${STACKDIO_USER}.keytab
chmod 400 ${STACKDIO_USER}.keytab
