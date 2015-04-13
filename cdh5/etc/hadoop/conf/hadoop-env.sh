
{% if salt['pillar.get']('cdh5:security:enable', False) %}
export HADOOP_OPTS="$HADOOP_OPTS -Djava.security.krb5.conf={{ pillar.krb5.conf_file }}"
{% endif %}