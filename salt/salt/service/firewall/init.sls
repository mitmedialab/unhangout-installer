{% from 'vars.jinja' import public_interface, sshd_port, filter_tcp_ports, filter_udp_ports, raw_tcp_ports, raw_udp_ports with context %}

iptables-package:
  pkg.installed:
    - name: iptables

/etc/sysconfig/iptables:
  file.managed:
    - source: salt://etc/sysconfig/iptables.jinja
    - template: jinja
    - context:
      filter_tcp_ports: {{ filter_tcp_ports }}
      filter_udp_ports: {{ filter_udp_ports }}
      raw_tcp_ports: {{ raw_tcp_ports }}
      raw_udp_ports: {{ raw_udp_ports }}
      sshd_port: {{ sshd_port }}
      public_interface: {{ public_interface }}
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
