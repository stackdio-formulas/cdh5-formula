{% if salt['pillar.get']('cdh5:landing_page', True) %}

{% set settings = salt['grains.filter_by']({
      'Debian': {
          'package_name': 'apache2',
          'html_file': '/var/www/index.html',
      },
      'RedHat': {
          'package_name': 'httpd',
          'html_file': '/var/www/index.html',
      },
}) %}


# Install thttpd or apache
webserver:
  pkg:
    - installed
    - name: {{ settings.package_name }}
  service:
    - running
    - name: {{ settings.package_name }}
    - require:
      - pkg: webserver
      - file: landing_html
      - file: /etc/httpd/conf.d/welcome.conf

/etc/httpd/conf.d/welcome.conf:
  file:
    - absent
    - require:
      - pkg: webserver

# Setup the landing page
landing_html:
  file:
    - managed
    - name: {{ settings.html_file }}
    - source: salt://cdh5/landing_page/index.html
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: true
    - require:
      - pkg: webserver

{% endif %}
