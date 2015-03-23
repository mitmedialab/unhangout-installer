include:
  - service.nodejs
  - service.npm
  - service.redis
  - service.monit

{% from 'vars.jinja' import server_env, server_type, google_client_id, google_client_secret, google_project_id, google_spreadsheet_key, unhangout_session_secret, unhangout_server_email_address, unhangout_superuser_emails, unhangout_managers, unhangout_email_log_recipients, unhangout_node_env, unhangout_domain, unhangout_https_port, unhangout_localhost_port, unhangout_git_url, unhangout_git_branch, redis_host, redis_port, redis_db with context -%}


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

# Set up the dependency line for the Git checkout. This is necessary because on
# Vagrant installs the checkout is an existing linked folder on the VM.
{% set unhangout_git_checkout_dependency = server_type == 'vagrant' and 'file: /usr/local/node/unhangout' or 'git: unhangout-github' -%}
# unhangout_git_checkout_dependency is {{ unhangout_git_checkout_dependency }}


/usr/local/node/unhangout:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: /usr/local/node

/var/log/node/unhangout:
  file.directory:
    - user: node
    - group: node
    - dir_mode: 755
    - require:
      - file: /var/log/node
      - user: node-user
      - group: node-group

{% if server_type != 'vagrant' -%}
unhangout-github:
  git.latest:
    - name: {{ unhangout_git_url }}
    - rev: {{ unhangout_git_branch }}
    - target: /usr/local/node/unhangout
    - require:
      - file: /usr/local/node/unhangout
{% endif -%}

# This directory is created up front so the production node user can write to
# it.
/usr/local/node/unhangout/public/logs/chat:
  file.directory:
# Development machines can have more lax security standards, and having the
# root user own this file completely aids in Vagrant installs.
{% if server_env == 'development' %}
    - user: root
    - group: root
    - mode: 755
{% else %}
    - user: node
    - group: node
    - mode: 750
{% endif %}
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - group: node-group
      - {{ unhangout_git_checkout_dependency }}

/usr/local/node/unhangout/conf.json:
  file:
    - managed
    - template: jinja
    - context:
      google_client_id: {{ google_client_id }}
      google_client_secret: {{ google_client_secret }}
      google_project_id: {{ google_project_id }}
      google_spreadsheet_key: {{ google_spreadsheet_key }}
      unhangout_session_secret: {{ unhangout_session_secret }}
      unhangout_server_email_address: {{ unhangout_server_email_address }}
      unhangout_superuser_emails: {{ unhangout_superuser_emails }}
      unhangout_managers: {{ unhangout_managers }}
      unhangout_email_log_recipients: {{ unhangout_email_log_recipients }}
      unhangout_domain: {{ unhangout_domain }}
      unhangout_https_port: {{ unhangout_https_port }}
      unhangout_localhost_port: {{ unhangout_localhost_port }}
      redis_host: {{ redis_host }}
      redis_port: {{ redis_port }}
      redis_db: {{ redis_db }}
    - source: salt://service/unhangout/conf.json.jinja
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
      - {{ unhangout_git_checkout_dependency }}

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

npm-bootstrap-unhangout:
  npm.bootstrap:
    - name: /usr/local/node/unhangout
    - require:
      - pkg: npm
    - watch:
      - {{ unhangout_git_checkout_dependency }}
      - file: /usr/local/node/unhangout/conf.json

unhangout-compile-assets:
  cmd.wait:
    - name: bin/compile-assets.js
    - cwd: /usr/local/node/unhangout
    - watch:
      - {{ unhangout_git_checkout_dependency }}
    - require:
      - npm: npm-bootstrap-unhangout

/etc/init.d/unhangout:
  file:
    - managed
    - source: salt://etc/init.d/node
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: unhangout-compile-assets

/etc/sysconfig/unhangout:
  file:
    - managed
    - template: jinja
    - context:
      server_env: {{ server_env }}
      unhangout_node_env: {{ unhangout_node_env }}
    - source: salt://etc/sysconfig/node.jinja
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: unhangout-compile-assets

{% if server_env == 'production' -%}
unhangout-service:
  service:
    - running
    - name: unhangout
    - enable: True
    - restart: True
    - watch:
      - pkg: nodejs
      - {{ unhangout_git_checkout_dependency }}
      - file: /usr/local/node/unhangout/conf.json
      - file: /etc/pki/tls/private/{{ unhangout_domain }}.key
      - file: /etc/pki/tls/certs/{{ unhangout_domain }}.crt
      - cmd: unhangout-compile-assets
      - npm: npm-bootstrap-unhangout
      - file: /etc/init.d/unhangout
      - file: /etc/sysconfig/unhangout
    - require:
      - file: /var/log/node/unhangout

/etc/monit.d/unhangout:
  file:
    - managed
    - template: jinja
    - context:
      unhangout_https_port: {{ unhangout_https_port }}
    - source: salt://etc/monit.d/unhangout.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
      - service: unhangout-service
{% endif -%}

extend:
{% if server_env == 'production' %}
  monit-service:
    service:
      - watch:
        - file: /etc/monit.d/unhangout
{% endif %}
  redis-service:
    service:
      - watch:
        - file: /usr/local/node/unhangout/conf.json
