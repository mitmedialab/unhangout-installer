{% from 'vars.jinja' import sshd_port, unhangout_https_port, nat_https_port, nginx_http_port with context %}

iptables-package:
  pkg.installed:
    - name: iptables

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://etc/sysconfig/iptables.jinja
    - template: jinja
    - context:
      sshd_port: {{ sshd_port }}
      unhangout_https_port: {{ unhangout_https_port }}
      nat_https_port: {{ nat_https_port }}
      nginx_http_port: {{ nginx_http_port }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables-package


iptables-service:
  service.running:
    - name: iptables
    - enable: true
    - watch:
      - pkg: iptables-package
      - file: /etc/sysconfig/iptables
