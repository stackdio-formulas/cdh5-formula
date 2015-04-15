{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
{%- set user = pillar.__stackdio__.username -%}
#!/bin/bash
export KRB5_CONFIG={{ pillar.krb5.conf_file }}
rm -rf *.keytab
(
echo "addprinc -randkey {{ user }}/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k {{ user }}.keytab {{ user }}/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}

chown {{ user }}:{{ user }} {{ user }}.keytab
chmod 400 {{ user }}.keytab
