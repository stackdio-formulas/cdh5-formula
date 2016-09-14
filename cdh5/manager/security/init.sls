{% if pillar.cdh5.security.enable %}
{%- from 'krb5/settings.sls' import krb5 with context %}
{%- set realm = krb5.realm -%}
create_scm_principal:
  cmd:
    - run
    - name: 'echo "addprinc -pw cloudera cloudera-scm/admin@{{ realm }}" | kadmin -p kadmin/admin -kt /root/admin.keytab -r {{ realm }}'
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - module: load_admin_keytab
{% endif %}
