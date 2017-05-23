
# From cloudera, CDH5 requires JDK7, so include it along with the 
# CDH5 repository to install their packages.
include:
  - cdh5.repo
  - cdh5.hadoop.conf
  - cdh5.landing_page
  - cdh5.hadoop.client
  {% if salt['pillar.get']('cdh5:datanode:start_service', True) %}
  - cdh5.hadoop.nodemanager.service
  - cdh5.hadoop.hdfsnode.service
  {% endif %}
  {% if pillar.cdh5.encryption.enable %}
  - cdh5.hadoop.encryption
  {% endif %}
  {% if pillar.cdh5.security.enable %}
  - krb5
  - cdh5.security
  - cdh5.security.stackdio_user
  - cdh5.hadoop.security
  {% endif %}
  - cdh5.hadoop.nodemanager
  - cdh5.hadoop.hdfsnode

