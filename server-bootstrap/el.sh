#!/bin/bash

echo
echo "This script will perform the basic preliminary setup to configure a
server as a standalone Salt minion. Should work on all current versions of
RHEL/CentOS. After the script completes, some further configuration will be
necessary, which will be noted upon completion.

Before continuing, ensure that the server has access to the internet, including
DNS resolution, and a valid, fully qualified host name configured."
echo

echo -n "Enter server environment (development or production, default is
development): "
read SERVER_ENV

SERVER_HOSTNAME=`hostname`

# Log messages to syslog and console.
log() {
  local message=$1
  logger "SETUP: $message"
  echo "$message"
}

log "Installing EPEL"
yum -y install epel-release

log "Installing salt-minion"
yum -y install salt-minion

log "Configuring minion file."
cat > /etc/salt/minion << EOF
id: $SERVER_HOSTNAME
file_client: local
state_auto_order: True

file_roots:
  base:
    - /srv/salt/salt

pillar_roots:
  base:
    - /srv/salt/pillar

grains:
  server:
    env: ${SERVER_ENV:-development}
EOF

echo
echo "Basic configuration complete.

The following actions are needed:

 * Place your salt configuration at /srv/salt/salt
 * Place your pillar configuration at /srv/salt/pillar
 * Run 'salt-call state.highstate'"

echo

exit 0
