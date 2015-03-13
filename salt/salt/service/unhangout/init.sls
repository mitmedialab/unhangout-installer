include:
  - service.nodejs
  - service.npm
  - service.redis
  - service.monit

{% from 'vars.jinja' import server_env, google_client_id, google_client_secret, google_project_id, google_spreadsheet_key, unhangout_session_secret, unhangout_server_email_address, unhangout_superuser_emails, unhangout_managers, unhangout_email_log_recipients, unhangout_node_env, unhangout_domain, unhangout_https_port, unhangout_localhost_port, unhangout_git_url, unhangout_git_branch, redis_host, redis_port, redis_db with context -%}


# Figure out if SSL files exist for install.
{% set ssl_install = [] -%}
{% set ssl_file_path = 'service/unhangout/ssl' -%}
# For each directory that can have files.
{% for root in opts['file_roots']['base'] -%}
  # Check for existing .key and .crt files that match the unhangout domain.
  {% set key_file_exists = salt['file.file_exists']('{0}/{1}/{2}.key'.format(root, ssl_file_path, unhangout_domain)) -%}
  {% set crt_file_exists = salt['file.file_exists']('{0}/{1}/{2}.crt'.format(root, ssl_file_path, unhangout_domain)) -%}
  # If both exist, set up for install.
  {% if key_file_exists and crt_file_exists -%}
    {% if ssl_install.append(1) %}{% endif -%}
  {% endif -%}
{% endfor -%}
# ssl_install is {{ ssl_install|length }}

/usr/local/node/unhangout:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - pkg: nodejs
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

unhangout-github:
  git.latest:
    - name: {{ unhangout_git_url }}
    - rev: {{ unhangout_git_branch }}
    - target: /usr/local/node/unhangout
    - require:
      - file: /usr/local/node/unhangout

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
    - group: node
    - mode: 640
    - require:
      - pkg: nodejs
      - group: node-group
      - git: unhangout-github

{% if ssl_install -%}
/usr/local/node/unhangout/ssl:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - git: unhangout-github

/usr/local/node/unhangout/ssl/{{ unhangout_domain }}.key:
  file:
    - managed
    - source: salt://service/unhangout/ssl/{{ unhangout_domain }}.key
    - user: root
    - group: node
    - mode: 640
    - require:
      - pkg: nodejs
      - file: /usr/local/node/unhangout/ssl

/usr/local/node/unhangout/ssl/{{ unhangout_domain }}.crt:
  file:
    - managed
    - source: salt://service/unhangout/ssl/{{ unhangout_domain }}.crt
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: /usr/local/node/unhangout/ssl
{% endif %}

npm-bootstrap-unhangout:
  npm.bootstrap:
    - name: /usr/local/node/unhangout
    - require:
      - pkg: npm
      - file: /usr/local/node/unhangout/conf.json
    - watch:
      - git: unhangout-github

unhangout-compile-assets:
  cmd.wait:
    - name: bin/compile-assets.js
    - cwd: /usr/local/node/unhangout
    - watch:
      - git: unhangout-github
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
      unhangout_node_env: {{ unhangout_node_env }}
    - source: salt://etc/sysconfig/node.jinja
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: unhangout-compile-assets

unhangout-service:
  service:
    - running
    - name: unhangout
    - enable: True
    - restart: True
    - watch:
      - pkg: nodejs
      - git: unhangout-github
      - file: /usr/local/node/unhangout/conf.json
{% if ssl_install %}
      - file: /usr/local/node/unhangout/ssl/{{ unhangout_domain }}.key
      - file: /usr/local/node/unhangout/ssl/{{ unhangout_domain }}.crt
{% endif %}
      - cmd: unhangout-compile-assets
      - npm: npm-bootstrap-unhangout
      - file: /etc/init.d/unhangout
      - file: /etc/sysconfig/unhangout
    - require:
      - file: /var/log/node/unhangout

{% if server_env == 'production' -%}
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
