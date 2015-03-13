include:
  - service.nodejs

npm:
  pkg.installed:
    - require:
      - pkg: nodejs
