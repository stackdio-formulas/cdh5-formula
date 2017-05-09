{% if salt['pillar.get']('cdh5:landing_page', True) %}

# Install nginx
webserver:
  pkg:
    - installed
    - name: nginx
  service:
    - running
    - name: nginx
    - enable: true
    - require:
      - pkg: webserver
      - file: landing_html

# Setup the landing page
landing_html:
  file:
    - managed
    - name: /usr/share/nginx/html/index.html
    - source: salt://cdh5/landing_page/index.html
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: true
    - require:
      - pkg: webserver

{% endif %}
