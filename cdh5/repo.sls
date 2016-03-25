{% if grains.os_family == 'Debian' %}

# Add the appropriate CDH5 repository. See http://archive.cloudera.com/cdh5
# for which distributions and versions are supported.
/etc/apt/sources.list.d/cloudera.list:
  file:
    - managed
    - name: /etc/apt/sources.list.d/cloudera.list
    - source: salt://cdh5/etc/apt/sources.list.d/cloudera.list.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: add_policy_file

cdh5_gpg:
  cmd:
    - run
    - name: 'curl -s http://archive.cloudera.com/cdh5/ubuntu/{{ grains.lsb_distrib_codename }}/amd64/cdh/archive.key | apt-key add -'
    - unless: 'apt-key list | grep "Cloudera Apt Repository"'
    - require:
      - file: /etc/apt/sources.list.d/cloudera.list

cdh5_refresh_db:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - cmd: cdh5_gpg

# This is used on ubuntu so that services don't start 
add_policy_file:
  file:
    - managed
    - name: /usr/sbin/policy-rc.d
    - contents: exit 101
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

remove_policy_file:
  file:
    - absent
    - name: /usr/sbin/policy-rc.d
    - order: last
    - require:
      - file: add_policy_file

{% elif grains.os_family == 'RedHat' %}

{% set releasever = grains.osmajorrelease %}

# Set up the CDH5 yum repository
cloudera_cdh5:
  pkgrepo:
    - managed
    - humanname: "Cloudera's Distribution for Hadoop, Version 5"
    - baseurl: "http://archive.cloudera.com/cdh5/redhat/{{ releasever }}/x86_64/cdh/{{ pillar.cdh5.version }}/"
    - gpgkey: http://archive.cloudera.com/cdh5/redhat/{{ releasever }}/x86_64/cdh/RPM-GPG-KEY-cloudera
    - gpgcheck: 1

cdh5_gpg:
  cmd:
    - run
    - name: 'rpm --import http://archive.cloudera.com/cdh5/redhat/{{ releasever }}/x86_64/cdh/RPM-GPG-KEY-cloudera'
    - unless: 'rpm -qi gpg-pubkey-e8f86acd'
    - require:
      - pkgrepo: cloudera_cdh5

cdh5_refresh_db:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - cmd: cdh5_gpg

{% endif %}

