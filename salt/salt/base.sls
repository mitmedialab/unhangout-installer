{% from 'vars.jinja' import server_id, unhangout_domain, nginx_custom_domain with context %}

etc-hosts-entries:
  host.present:
    - ip: 127.0.0.1
    - names:
      - localhost
      - {{ server_id }}
      - {{ unhangout_domain }}
{% if nginx_custom_domain %}
      - {{ nginx_custom_domain }}
{% endif %}

/etc/sysctl.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

/usr/local/bin/apply_sysctl.sh:
  file.managed:
    - source: salt://script/apply_sysctl.sh
    - user: root
    - group: root
    - mode: 755

