{% set files = ['logging', 'main'] %}

monit:
  pkg.installed

{% for file in files %}
/etc/monit.d/{{ file }}:
  file:
    - managed
    - source: salt://etc/monit.d/{{ file }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
{% endfor %}

monit-service:
  service:
    - running
    - name: monit
    - enable: True
    - restart: True
    - require:
      - pkg: monit
    - watch:
      {% for file in files %}
      - file: /etc/monit.d/{{ file }}
      {% endfor %}

