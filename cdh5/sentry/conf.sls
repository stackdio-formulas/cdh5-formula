/etc/sentry/conf:
  file:
    - recurse
    - source: salt://cdh5/etc/sentry/conf
    - template: jinja
    - user: root
    - group: root
    - file_mode: 644
    - exclude_pat: '.*.swp'
