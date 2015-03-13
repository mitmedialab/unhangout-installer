/etc/selinux/config:
  file:
    - managed
    - source: salt://etc/selinux/config
    - user: root
    - group: root
    - mode: 644

