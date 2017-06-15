{% set standby = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.yarn.standby-resourcemanager', 'grains.items', 'compound') %}

##
# Starts yarn resourcemanager service.
#
# Depends on: JDK7
##
hadoop-yarn-resourcemanager-svc:
  service:
    - running
    - name: hadoop-yarn-resourcemanager
    - enable: true
    - require:
      - pkg: hadoop-yarn-resourcemanager
    - watch:
      - file: /etc/hadoop/conf

{% if standby %}
hadoop-yarn-proxyserver-svc:
  service:
    - running
    - name: hadoop-yarn-proxyserver
    - enable: true
    - require:
      - pkg: hadoop-yarn-proxyserver
    - watch:
      - file: /etc/hadoop/conf
{% endif %}
