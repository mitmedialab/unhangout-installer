{% from 'vars.jinja' import server_env, server_id with context %}

/etc/sysconfig/network:
  file:
    - managed
    - template: jinja
    - context:
      server_env: {{ server_env }}
      server_id: {{ server_id }}
    - source: salt://etc/sysconfig/network.jinja
    - user: root
    - group: root
    - mode: 644

network-service:
  service.running:
    - name: network
    - enable: true
    - watch:
      - file: /etc/sysconfig/network
