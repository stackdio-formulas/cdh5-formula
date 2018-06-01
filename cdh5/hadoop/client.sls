
{%- set libcrypto_pkg = salt['grains.filter_by']({
  'RedHat': 'openssl-devel',
  'Debian': 'libssl-dev'
}, default='RedHat') -%}

include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - cdh5.hadoop.hdfs.security
  {% endif %}

hadoop-client: 
  pkg.installed:
    - pkgs:
      - hadoop-client
      - {{ libcrypto_pkg }}
    - require:
      - module: cdh5_refresh_db
      {% if pillar.cdh5.security.enable %}
      - file: krb5_conf_file
      {% endif %}
    - require_in:
      - file: /etc/hadoop/conf
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

