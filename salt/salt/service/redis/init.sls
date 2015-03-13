include:
  - base
  - service.monit

{% from 'vars.jinja' import redis_host, redis_port with context %}

redis-package:
  pkg.installed:
    - name: redis

/etc/redis.conf:
  file:
    - managed
    - source: salt://etc/redis.conf.jinja
    - template: jinja
    - context:
      redis_host: {{ redis_host }}
      redis_port: {{ redis_port }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: redis-package

/etc/sysctl.d/redis.conf:
  file:
    - managed
    - source: salt://etc/sysctl.d/redis.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: redis-package
      - file: /etc/sysctl.d

redis-sysctl-reload-sysctl:
  cmd.wait:
    - name: /usr/local/bin/apply_sysctl.sh
    - cwd: /
    - prereq:
      - file: /etc/sysctl.d/redis.conf

redis-service:
  service:
    - running
    - name: redis
    - enable: True
    - watch:
      - pkg: redis-package
      - file: /etc/redis.conf
      - file: /etc/sysctl.d/redis.conf

/etc/monit.d/redis:
  file:
    - managed
    - source: salt://etc/monit.d/redis.jinja
    - template: jinja
    - context:
      redis_host: {{ redis_host }}
      redis_port: {{ redis_port }}
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: monit
      - pkg: redis-package

extend:
  monit-service:
    service:
      - watch:
        - file: /etc/monit.d/redis
