{% set standby = salt['mine.get']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh5.hadoop.hdfs.standby-namenode', 'grains.items', 'compound') %}
{% set dfs_name_dir = salt['pillar.get']('cdh5:dfs:name_dir', '/mnt/hadoop/hdfs/nn') %}

##
# Starts the namenode service.
#
# Depends on: JDK7
##

##
# Make sure the namenode metadata directory exists
# and is owned by the hdfs user
##
cdh5_dfs_dirs:
  cmd.run:
    - name: 'mkdir -p {{ dfs_name_dir }} && chown -R hdfs:hdfs `dirname {{ dfs_name_dir }}`'
    - unless: 'test -d {{ dfs_name_dir }}'
    - require:
      - pkg: hadoop-hdfs-namenode
      - file: /etc/hadoop/conf
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}

# Initialize HDFS. This should only run once, immediately
# following an install of hadoop.
init_hdfs:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs namenode -format -force'
    - unless: 'test -d {{ dfs_name_dir }}/current'
    - require:
      - cmd: cdh5_dfs_dirs
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}

hadoop-hdfs-namenode-svc:
  service.running:
    - name: hadoop-hdfs-namenode
    - enable: true
    - require:
      - pkg: hadoop-hdfs-namenode
      - cmd: init_hdfs
      - cmd: hadoop-hdfs-namenode-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf

{% if standby %}
init_zkfc:
  cmd.run:
    - name: hdfs zkfc -formatZK
    - user: hdfs
    - group: hdfs
    - unless: 'zookeeper-client stat /hadoop-ha/{{ grains.namespace }} 2>&1 | grep "cZxid"'
    - require:
      - pkg: hadoop-hdfs-namenode
      - cmd: cdh5_dfs_dirs

# Start up the ZKFC
hadoop-hdfs-zkfc-svc:
  service.running:
    - name: hadoop-hdfs-zkfc
    - enable: true
    - require:
      - pkg: hadoop-hdfs-namenode
      - cmd: init_zkfc
      - cmd: hadoop-hdfs-zkfc-init-script
      {% if pillar.cdh5.encryption.enable %}
      - cmd: chown-keystore
      {% endif %}
      {% if pillar.cdh5.security.enable %}
      - cmd: generate_hadoop_keytabs
      {% endif %}
    - watch:
      - file: /etc/hadoop/conf
{% endif %}

# When security is enabled, we need to get a kerberos ticket
# for the hdfs principal so that any interaction with HDFS
# through the hadoop client may authorize successfully.
# NOTE this means that any 'hdfs dfs' commands will need
# to require this state to be sure we have a krb ticket
{% if pillar.cdh5.security.enable %}
hdfs_kinit:
  cmd.run:
    - name: 'kinit -kt /etc/hadoop/conf/hdfs.keytab hdfs/{{ grains.fqdn }}'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: generate_hadoop_keytabs
    - require_in:
      - cmd: hdfs_tmp_dir

hdfs_kdestroy:
  cmd.run:
    - name: 'kdestroy'
    - user: hdfs
    - group: hdfs
    - env:
      - KRB5_CONFIG: '{{ pillar.krb5.conf_file }}'
    - require:
      - cmd: hdfs_kinit
      - cmd: hdfs_tmp_dir
{% endif %}

# HDFS tmp directory
hdfs_tmp_dir:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir /tmp && hdfs dfs -chmod -R 1777 /tmp'
    - unless: 'hdfs dfs -test -d /tmp'
    - require:
      - service: hadoop-hdfs-namenode-svc

# create a user directory for each user
{% for user_obj in pillar.__stackdio__.users %}
{% set user = user_obj.username %}
hdfs_dir_{{ user }}:
  cmd.run:
    - user: hdfs
    - group: hdfs
    - name: 'hdfs dfs -mkdir -p /user/{{ user }} && hdfs dfs -chown {{ user }}:{{ user }} /user/{{ user }}'
    - require:
      - service: hadoop-hdfs-namenode-svc
      {% if pillar.cdh5.security.enable %}
      - cmd: hdfs_kinit
      {% endif %}
    {% if pillar.cdh5.security.enable %}
    - require_in:
      - cmd: hdfs_kdestroy
    {% endif %}
{% endfor %}
