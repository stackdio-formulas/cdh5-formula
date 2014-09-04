sentry_init_schema:
  cmd:
    - run
    - name: '/usr/bin/sentry --command schema-tool --conffile /etc/sentry/conf/sentry-site.xml --dbType derby --initSchema'
    - unless: 'test -d /etc/sentry/store'
    - cwd: '/etc/sentry'
    - require:
      - pkg: sentry
      - cmd: generate_sentry_keytabs

sentry_log_dir:
  cmd:
    - run
    - name: 'mkdir -p /var/log/sentry && chown -R sentry:sentry /var/log/sentry'
    - unless: 'test -d /var/log/sentry'
    - require:
      - pkg: sentry

sentry_service:
  cmd:
    - run
    - name: 'nohup /usr/bin/sentry --log4jConf /etc/sentry/conf/sentry-log4j.properties --command service --conffile /etc/sentry/conf/sentry-site.xml &> /var/log/sentry/sentry.log &'
    - unless: 'ps auxw | grep -e "--command service.*sentry-site" | grep -v grep'
    - require:
      - cmd: sentry_init_schema
      - cmd: sentry_log_dir

load_policies:
  cmd:
    - run
    - name: 'sleep 5 && sentry --command config-tool -s file:///etc/sentry/conf/sentry-site.xml -I'
    - require:
      - cmd: sentry_service
