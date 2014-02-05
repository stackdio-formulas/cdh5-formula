{% if pillar.get('cdh5.landing_page', True) %}
#
# Install thttpd
thttpd:
  pkg:
    - installed
  service:
    - running
    - require:
      - pkg: thttpd
      - file: /var/www/thttpd/index.html

# Setup the landing page
/var/www/thttpd/index.html:
  file:
    - managed
    - source: salt://cdh5/landing_page/index.html
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - pkg: thttpd

{% endif %}
