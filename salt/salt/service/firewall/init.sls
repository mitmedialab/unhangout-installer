{% from 'vars.jinja' import server_env, sshd_port, unhangout_https_port, nginx_http_port, nginx_https_port, firewall_custom_configs with context %}

iptables-package:
  pkg.installed:
    - name: iptables

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://etc/sysconfig/iptables.jinja
    - template: jinja
    - context:
      server_env: {{ server_env }}
      sshd_port: {{ sshd_port }}
      unhangout_https_port: {{ unhangout_https_port }}
      nginx_http_port: {{ nginx_http_port }}
      nginx_https_port: {{ nginx_https_port }}
      firewall_custom_configs: {{ firewall_custom_configs }}
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
