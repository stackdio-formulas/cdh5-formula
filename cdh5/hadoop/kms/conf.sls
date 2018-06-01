/etc/hadoop-kms/conf:
  file.recurse:
    - source: salt://cdh5/etc/hadoop-kms/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - exclude_pat: '.*.swp'