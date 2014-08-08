# Set up the CM repository
cloudera_manager_repo:
  pkgrepo:
    - managed
    - humanname: "Cloudera Manager"
    - baseurl: 'http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/'
    - gpgkey: 'http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera'
    - gpgcheck: 1

cloudera_manager_gpg:
  cmd:
    - run
    - name: 'rpm --import http://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera'
    - unless: 'rpm -qi gpg-pubkey-e8f86acd'
    - require:
      - pkgrepo: cloudera_manager_repo

cloudera_manager_repo_refresh:
  module:
    - run
    - name: pkg.refresh_db
    - require:
      - cmd: cloudera_manager_gpg
