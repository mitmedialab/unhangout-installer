{% from 'vars.jinja' import server_env with context -%}

base:
  '*':
    - early-packages
    - update-packages
    - repo
    - base-packages
    - service.network
    - service.firewall
    - auth.dev-root
    - service.ssh
    - base
    - selinux
    - service.salt-minion
    - service.monit
    - service.redis
{% if server_env == 'production' %}
    - service.nginx
{% endif %}
    - service.nodejs
    - service.npm
    - service.unhangout
    - misc
