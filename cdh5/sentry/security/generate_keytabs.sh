{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash
export KRB5_CONFIG={{ pillar.krb5.conf_file }}
cd /etc/sentry/conf
rm -rf *.keytab
(
echo "addprinc -randkey sentry/{{ grains.fqdn }}"
echo "xst -k sentry.keytab sentry/{{ grains.fqdn }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown sentry:sentry sentry.keytab
chmod 400 *.keytab
