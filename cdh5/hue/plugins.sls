{% set hue_plugin_dir='/usr/share/hue/desktop/libs/hadoop/java-lib' %}
{% set hue_plugin_jar='/usr/lib/hadoop-0.20-mapreduce/lib/hue-plugins.jar' %}

hue-plugin-jar:
  cmd:
    - run
    - name: "ln -s $(find {{ hue_plugin_dir }} -type f -name 'hue-plugins-*.jar') {{ hue_plugin_jar }}"
    - unless: "test -L {{ hue_plugin_jar }}"
    - require:
      - pkg: hue

# the jobtracker needs to be restarted to pickup this jar - but only if
# we're actually starting things up
{% if salt['pillar.get']('cdh5:hue:start_service', True) and salt['pillar.get']('cdh5:hadoop:namenode:start_service', True) %}
restart-jobtracker:
  cmd:
    - wait
    - name: "service hadoop-0.20-mapreduce-jobtracker restart"
    - user: root
    - watch:
      - cmd: hue-plugin-jar
{% endif %}

