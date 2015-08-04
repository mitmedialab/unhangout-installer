{% from 'vars.jinja' import server_env, server_type, google_client_id, google_client_secret, google_project_id, google_spreadsheet_key, unhangout_session_secret, unhangout_server_email_address, unhangout_superuser_emails, unhangout_managers, unhangout_email_log_recipients, unhangout_node_env, unhangout_domain, unhangout_https_port, unhangout_localhost_port, unhangout_git_url, unhangout_git_branch, redis_host, redis_port, redis_db with context -%}

{% set www_domain = unhangout_domain -%}
{% set ssl_domain = unhangout_domain -%}

include:
  - service.nodejs
  - service.npm
  - service.redis
  - service.unhangout.ssl
{% if server_env == 'production' %}
  - service.monit
{% endif %}

# Set up the dependency line for the Git checkout. This is necessary because on
# Vagrant installs the checkout is an existing linked folder on the VM.
{% set unhangout_git_checkout_dependency = server_type == 'vagrant' and ('file: /usr/local/node/unhangout-' + unhangout_domain) or ('git: ' + unhangout_domain + '-github') -%}
# unhangout_git_checkout_dependency is {{ unhangout_git_checkout_dependency }}


/usr/local/node/unhangout-{{ unhangout_domain }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: /usr/local/node

/var/log/node/unhangout-{{ unhangout_domain }}:
  file.directory:
    - user: node
    - group: node
    - dir_mode: 755
    - require:
      - file: /var/log/node
      - user: node-user
      - group: node-group

{% if server_type != 'vagrant' -%}
{{ unhangout_domain }}-github:
  git.latest:
    - name: {{ unhangout_git_url }}
    - rev: {{ unhangout_git_branch }}
    - target: /usr/local/node/unhangout-{{ unhangout_domain }}
    - require:
      - file: /usr/local/node/unhangout-{{ unhangout_domain }}
{% endif -%}

# This directory is created up front so the production node user can write to
# it.
/usr/local/node/unhangout-{{ unhangout_domain }}/public/logs/chat:
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

/usr/local/node/unhangout-{{ unhangout_domain }}/conf.json:
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
      www_domain: {{ www_domain }}
      ssl_domain: {{ ssl_domain }}
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

npm-bootstrap-{{ unhangout_domain }}:
  npm.bootstrap:
    - name: /usr/local/node/unhangout-{{ unhangout_domain }}
    - require:
      - pkg: npm
    - watch:
      - {{ unhangout_git_checkout_dependency }}
      - file: /usr/local/node/unhangout-{{ unhangout_domain }}/conf.json

# This directory is created up front so the production node user can write to
# it.
/usr/local/node/unhangout-{{ unhangout_domain }}/node_modules/googleapis/.cache:
  file.directory:
# Development machines can have more lax security standards, and having the
# root user own this file completely aids in Vagrant installs.
{% if server_env == 'development' %}
    - user: root
    - group: root
    - mode: 755
{% else %}
    - user: root
    - group: node
    - mode: 775
{% endif %}
    - require:
      - group: node-group
      - npm: npm-bootstrap-{{ unhangout_domain }}

{% if server_env == 'production' -%}
{{ unhangout_domain }}-compile-assets:
  cmd.wait:
    - name: bin/compile-assets.js
    - cwd: /usr/local/node/unhangout-{{ unhangout_domain }}
    - watch:
      - {{ unhangout_git_checkout_dependency }}
    - require:
      - npm: npm-bootstrap-{{ unhangout_domain }}
{% endif -%}

/etc/init.d/unhangout-{{ unhangout_domain }}:
  file:
    - managed
    - source: salt://etc/init.d/node
    - user: root
    - group: root
    - mode: 755
{% if server_env == 'production' %}
    - require:
      - cmd: {{ unhangout_domain }}-compile-assets
{% endif -%}

/etc/sysconfig/unhangout-{{ unhangout_domain }}:
  file:
    - managed
    - template: jinja
    - context:
      server_env: {{ server_env }}
      unhangout_node_env: {{ unhangout_node_env }}
      unhangout_domain: {{ unhangout_domain }}
    - source: salt://etc/sysconfig/node.jinja
    - user: root
    - group: root
    - mode: 755
{% if server_env == 'production' %}
    - require:
      - cmd: {{ unhangout_domain }}-compile-assets
{% endif -%}

{% if server_env == 'production' -%}
/etc/monit.d/unhangout-{{ unhangout_domain }}:
  file:
    - managed
    - template: jinja
    - context:
      unhangout_domain: {{ unhangout_domain }}
      unhangout_https_port: {{ unhangout_https_port }}
    - source: salt://etc/monit.d/unhangout.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
{% endif -%}

extend:
{% if server_env == 'production' %}
  monit-service:
    service:
      - watch:
        - pkg: nodejs
        - {{ unhangout_git_checkout_dependency }}
        - file: /usr/local/node/unhangout-{{ unhangout_domain }}/conf.json
        - cmd: {{ unhangout_domain }}-compile-assets
        - npm: npm-bootstrap-{{ unhangout_domain }}
        - file: /etc/init.d/unhangout-{{ unhangout_domain }}
        - file: /etc/sysconfig/unhangout-{{ unhangout_domain }}
        - file: /etc/monit.d/unhangout-{{ unhangout_domain }}
      - require:
        - file: /var/log/node/unhangout-{{ unhangout_domain }}
        - file: /usr/local/node/unhangout-{{ unhangout_domain }}/public/logs/chat
{% endif %}
  redis-service:
    service:
      - watch:
        - file: /usr/local/node/unhangout-{{ unhangout_domain }}/conf.json
