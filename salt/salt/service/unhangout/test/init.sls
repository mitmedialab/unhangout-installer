#!pyobjects

import os

server_env = grains("server:env", "development")
unhangout_selenium_version = pillar("service:unhangout:testing:selenium:version", "2.47.1")
selenium_base_version = os.path.splitext(unhangout_selenium_version)[0]
selenium_source_url = "http://selenium-release.storage.googleapis.com/%s/selenium-server-standalone-%s.jar" % (selenium_base_version, unhangout_selenium_version)
selenium_source_hash="e6cb10b8f0f353c6ca4a8f62fb5cb472",

include(
  "service.npm"
)

Pkg.installed(
  "test-packages",
  pkgs=[
    "xorg-x11-server-Xvfb",
    "firefox",
    "java-1.8.0-openjdk"
  ]
)

File.managed(
  "/usr/local/lib/selenium-server-standalone.jar",
  source=selenium_source_url,
  source_hash="md5=%s" % selenium_source_hash,
  user="root",
  group="root",
  mode="755"
)

if server_env == "development":
  Npm.installed(
    "mocha",
    user="root",
    require=Pkg("npm-package")
  )
