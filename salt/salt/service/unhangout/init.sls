{% from 'vars.jinja' import
  google_client_id,
  google_client_secret,
  google_project_id,
  google_spreadsheet_events_key,
  redis_db,
  redis_host,
  redis_port,
  server_env,
  server_type,
  unhangout_custom_css_files,
  unhangout_custom_facilitator_css_files,
  unhangout_domain,
  unhangout_email_log_recipients,
  unhangout_git_branch,
  unhangout_git_url,
  unhangout_hangout_urls_warning,
  unhangout_https_port,
  unhangout_managers,
  unhangout_mandrill_api_key,
  unhangout_node_env,
  unhangout_server_email_address,
  unhangout_session_secret,
  unhangout_superuser_emails,
  unhangout_testing_firefox_bin,
  unhangout_testing_selenium_path,
  unhangout_testing_selenium_verbose
with context -%}

{% set www_domain = unhangout_domain -%}
{% set ssl_domain = unhangout_domain -%}

{% include 'service/unhangout/install.sls' %}

