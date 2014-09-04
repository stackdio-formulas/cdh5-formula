{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
#!/bin/bash

echo "grant '{{user}}', 'RWXCA'" | hbase shell
echo "grant 'oozie', 'RWXCA'" | hbase shell
