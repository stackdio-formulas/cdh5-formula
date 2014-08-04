{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
{%- set user = pillar.__stackdio__.username -%}
#!/bin/bash
(
echo "addprinc -randkey {{ user }}/{{ grains.fqdn }}@{{ realm }}"
echo "xst -k {{ user }}.keytab {{ user }}/{{ grains.fqdn }}@{{ realm }}"
) | kadmin -p kadmin/admin -kt /root/admin.keytab

chown {{ user }}:{{ user }} {{ user }}.keytab
chmod 400 {{ user }}.keytab
