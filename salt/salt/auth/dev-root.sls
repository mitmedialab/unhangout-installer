{% set users = salt['pillar.get']('ssh:pubkeys:root', {}) -%}
{% for user, data in users.iteritems() %}
sshkey-{{ user }}:
  ssh_auth:
    - present
    - user: root
    - enc: {{ data.enc|default('ssh-rsa') }}
    - name: {{ data.key }}
    - comment: {{ user }}
{% endfor %}

