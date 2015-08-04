{% from 'vars.jinja' import server_env, unhangout_domain with context -%}

include:
  - service.nodejs
{% if server_env == 'production' %}
  - service.monit
{% endif %}

# Figure out if custom SSL files exist for install.
{% set custom_ssl_files_exist = [] -%}
{% set ssl_file_path = 'service/unhangout/ssl' -%}
# For each directory that can have files, skip the rest if files are found.
{% for root in opts['file_roots']['base'] if not custom_ssl_files_exist -%}
  # Check for existing .key and .crt files that match the unhangout domain.
  {% set key_file_exists = salt['file.file_exists']('{0}/{1}/{2}.key'.format(root, ssl_file_path, unhangout_domain)) -%}
  {% set crt_file_exists = salt['file.file_exists']('{0}/{1}/{2}.crt'.format(root, ssl_file_path, unhangout_domain)) -%}
  # If both exist, set up for install.
  {% if key_file_exists and crt_file_exists -%}
    {% if custom_ssl_files_exist.append(1) %}{% endif -%}
  {% endif -%}
{% endfor -%}
# custom_ssl_files_exist is {{ custom_ssl_files_exist|length }}
{% set ssl_domain = custom_ssl_files_exist and unhangout_domain or 'dummy' -%}
# ssl_domain is {{ ssl_domain }}

/etc/pki/tls/private/{{ unhangout_domain }}.key:
  file:
    - managed
    - source: salt://service/unhangout/ssl/{{ ssl_domain }}.key
    - user: root
# Development machines can have more lax security standards, and having the
# root user own this file completely aids in Vagrant installs.
{% if server_env == 'development' %}
    - group: root
    - mode: 644
{% else %}
    - group: node
    - mode: 640
{% endif %}
    - require:
      - group: node-group

/etc/pki/tls/certs/{{ unhangout_domain }}.crt:
  file:
    - managed
    - source: salt://service/unhangout/ssl/{{ ssl_domain }}.crt
    - user: root
    - group: root
    - mode: 644

{% if server_env == 'production' %}
extend:
  monit-service:
    service:
      - watch:
        - file: /etc/pki/tls/private/{{ unhangout_domain }}.key
        - file: /etc/pki/tls/certs/{{ unhangout_domain }}.crt
{% endif %}
