{% set hue_plugin_dir='/usr/lib/hue/desktop/libs/hadoop/java-lib/' %}
{% set hue_plugin_jar='/usr/lib/hadoop-0.20-mapreduce/lib/hue-plugins.jar' %}

hue-plugin-jar:
  cmd:
    - run
    - name: "ln -s $(find {{ hue_plugin_dir }} -type f -name 'hue-plugins-*.jar') {{ hue_plugin_jar }}"
    - unless: "test -L {{ hue_plugin_jar }}"
    - require:
      - pkg: hue
