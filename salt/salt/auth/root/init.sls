{% from 'vars.jinja' import
  ssh_pubkeys_root
with context %}

{% for user, data in ssh_pubkeys_root.iteritems() %}
sshkey-{{ user }}:
  ssh_auth:
    - present
    - user: root
    - enc: {{ data.enc|default('ssh-rsa') }}
    - name: {{ data.key }}
    - comment: {{ user }}
{% endfor %}

