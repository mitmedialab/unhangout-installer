{% from 'vars.jinja' import server_env, unhangout_domain, unhangout_https_port, unhangout_farming_email, unhangout_farming_password, unhangout_farming_hour, unhangout_farming_count with context %}

{% set www_domain = unhangout_domain %}

include:
  - service.unhangout.test

/usr/local/node/unhangout-{{ unhangout_domain }}/farmingConf.json:
  file:
    - managed
    - template: jinja
    - context:
      www_domain: {{ www_domain }}
      unhangout_https_port: {{ unhangout_https_port }}
      unhangout_farming_email: {{ unhangout_farming_email }}
      unhangout_farming_password: {{ unhangout_farming_password }}
      unhangout_farming_count: {{ unhangout_farming_count|int }}
    - source: salt://service/unhangout/autofarm/farmingConf.json.jinja
    - user: root
    - group: root
    - mode: 600

/usr/local/bin/autofarm-unhangout-{{ unhangout_domain }}:
  file:
    - managed
    - template: jinja
    - context:
      unhangout_domain: {{ unhangout_domain }}
    - source: salt://service/unhangout/autofarm/autofarm.jinja
    - user: root
    - group: root
    - mode: 700

{% if server_env == 'production' -%}
unhangout-{{ unhangout_domain }}-autofarm-cron:
  cron.present:
    - name: /usr/local/bin/autofarm-unhangout-{{ unhangout_domain }}
    - identifier: unhangout-{{ unhangout_domain }}-autofarm-cron
    - comment: Automates farming Google Hangout URLs as specified in farmingConf.json.
    - user: root
    - hour: {{ unhangout_farming_hour }}
    - minute: 0
{% endif -%}
