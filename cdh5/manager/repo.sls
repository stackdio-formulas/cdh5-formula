# Set up the CM repository
{% set releasever = grains.osmajorrelease %}

cloudera-manager-repo:
  pkgrepo.managed:
    - humanname: "Cloudera Manager"
    - baseurl: 'http://archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/{{ pillar.cdh5.manager.version }}/'
    - gpgkey: 'http://archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/RPM-GPG-KEY-cloudera'
    - gpgcheck: 1

cloudera-manager-gpg:
  cmd.run:
    - name: 'rpm --import http://archive.cloudera.com/cm5/redhat/{{ releasever }}/x86_64/cm/RPM-GPG-KEY-cloudera'
    - unless: 'rpm -qi gpg-pubkey-e8f86acd'
    - require:
      - pkgrepo: cloudera-manager-repo

cloudera-manager-repo-refresh:
  module.run:
    - name: pkg.refresh_db
    - require:
      - cmd: cloudera-manager-gpg
