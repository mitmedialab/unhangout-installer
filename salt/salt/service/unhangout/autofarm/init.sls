{% from 'vars.jinja' import server_env,
  unhangout_domain,
  unhangout_farming_count,
  unhangout_farming_email,
  unhangout_farming_hour,
  unhangout_farming_password,
  unhangout_https_port
with context %}

{% set www_domain = unhangout_domain %}

{% include 'service/unhangout/autofarm/install.sls' %}

