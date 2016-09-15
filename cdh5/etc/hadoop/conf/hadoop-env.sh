
export JAVA_HOME="/usr/java/latest"

{% if pillar.cdh5.security.enable %}
export HADOOP_OPTS="$HADOOP_OPTS -Djava.security.krb5.conf={{ pillar.krb5.conf_file }}"
export HADOOP_CLIENT_OPTS="$HADOOP_CLIENT_OPTS -Djava.security.krb5.conf={{ pillar.krb5.conf_file }}"
{% endif %}