{% from 'vars.jinja' import server_env with context -%}

# Figure out if custom directory exists with an init file for install.
{% set custom_init_file = [] -%}
# For each directory that can have files.
{% for root in opts['file_roots']['base'] -%}
  # Check for custom init file.
  {% set custom_init_file_exists = salt['file.file_exists']('{0}/custom/init.sls'.format(root)) -%}
  # If it exists set up for reading.
  {% if custom_init_file_exists -%}
    {% if custom_init_file.append(1) %}{% endif -%}
  {% endif -%}
{% endfor -%}
# custom_init_file is {{ custom_init_file|length }}

base:
  '*':
    - early-packages
    - update-packages
    - repo
    - base-packages
    - service.network
    - service.firewall
    - auth
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
{% if server_env == 'development' %}
    - service.unhangout.test
{% endif %}
{% if server_env == 'production' %}
    - service.unhangout.autofarm
{% endif %}
    - misc
{% if custom_init_file %}
    - custom
{% endif %}

