include:
  - service.monit

{% from 'vars.jinja' import unhangout_domain, unhangout_https_port, nginx_http_port, nginx_custom_domain with context %}

nginx-package:
  pkg.installed:
    - name: nginx

/etc/nginx/conf.d/default.conf:
  file:
    - managed
    - template: jinja
    - context:
      nginx_http_port: {{ nginx_http_port }}
      unhangout_domain: {{ unhangout_domain }}
      unhangout_https_port: {{ unhangout_https_port }}
    - source: salt://etc/nginx/conf.d/default.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx-package

{% if nginx_custom_domain %}

/etc/nginx/conf.d/{{ nginx_custom_domain }}.conf:
  file:
    - managed
    - template: jinja
    - context:
      nginx_http_port: {{ nginx_http_port }}
      nginx_custom_domain: {{ nginx_custom_domain }}
      unhangout_domain: {{ unhangout_domain }}
      unhangout_https_port: {{ unhangout_https_port }}
    - source: salt://etc/nginx/conf.d/{{ nginx_custom_domain }}.conf.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx-package

{% endif %}

nginx-service:
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - pkg: nginx-package
      - file: /etc/nginx/conf.d/default.conf
{% if nginx_custom_domain %}
      - file: /etc/nginx/conf.d/{{ nginx_custom_domain }}.conf
{% endif %}

/etc/monit.d/nginx:
  file:
    - managed
    - template: jinja
    - context:
      nginx_http_port: {{ nginx_http_port }}
    - source: salt://etc/monit.d/nginx.jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
      - pkg: nginx-package

extend:
  monit-service:
    service:
      - watch:
        - file: /etc/monit.d/nginx
