{% from 'vars.jinja' import server_timezone with context -%}

symlink-view-to-vim:
  file.symlink:
    - name: /usr/local/bin/view
    - target: /usr/bin/vim

symlink-timezone:
  file.symlink:
    - name: /etc/localtime
    - target: /usr/share/zoneinfo/{{ server_timezone }}
    # This cleanly allows removing the stock regular file, and/or switching
    # the symlink.
    - force: True
