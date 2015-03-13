base:
  '*':
    - service.network
    - service.firewall
    - auth.dev-root
    - service.ssh
    - base
    - selinux
    - early-packages
    - repo
    - base-packages
    - service.salt-minion
    - service.monit
    - service.redis
    - service.nginx
    - service.nodejs
    - service.npm
    - service.unhangout
    - misc
