include:
  - service.monit

{% from 'vars.jinja' import sshd_port with context %}

openssh-server:
  pkg.installed

/etc/ssh/sshd_config:
  file:
    - managed
    - template: jinja
    - context:
      sshd_port: {{ sshd_port }}
    - source: salt://etc/ssh/sshd_config.jinja
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: openssh-server

sshd-service:
  service.running:
    - enable: True
    - name: sshd
    - watch:
      - pkg: openssh-server
      - file: /etc/ssh/sshd_config

/etc/monit.d/sshd:
  file:
    - managed
    - template: jinja
    - context:
      sshd_port: {{ sshd_port }}
    - source: salt://etc/monit.d/sshd.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
      - pkg: openssh-server

extend:
  monit-service:
    service:
      - watch:
        - file: /etc/monit.d/sshd
