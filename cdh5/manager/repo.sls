# Set up the CM repository
{% set releasever = grains.osmajorrelease %}

cloudera_manager_repo:
  pkgrepo:
    - managed
    - humanname: "Cloudera Manager"
    - baseurl: 'https://{{pillar.cdh5.manager.cloudera_user}}:{{pillar.cdh5.manager.cloudera_password}}@archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/{{ pillar.cdh5.manager.version }}/'
    - gpgkey: 'https://{{pillar.cdh5.manager.cloudera_user}}:{{pillar.cdh5.manager.cloudera_password}}@archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/RPM-GPG-KEY-cloudera'
    - gpgcheck: 1

cloudera_manager_gpg:
  cmd:
    - run
    - name: 'rpm --import https://{{pillar.cdh5.manager.cloudera_user}}:{{pillar.cdh5.manager.cloudera_password}}@archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/RPM-GPG-KEY-cloudera'
    - unless: 'rpm -qi gpg-pubkey-e8f86acd'
    - require:
      - pkgrepo: cloudera_manager_repo

cloudera_manager_repo_refresh:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - cmd: cloudera_manager_gpg
