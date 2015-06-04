#!/bin/bash

# Handles the host layer of setting up an Unhangout development server.

DEV_SERVER=
SSH_PORT="2222"
SSH_CONFIG_LABEL="unhangout"
MESSAGE_STORE=""
VM_INSTALL_DIR="${HOME}/vagrant/unhangout"
UNHANGOUT_GIT_DIR="${HOME}/git/unhangout"
UNHANGOUT_GIT_URL="https://github.com/drewww/unhangout.git"
UNHANGOUT_GIT_BRANCH="master"

SCRIPT_NAME=`basename $0`

usage() {
echo "
This script handles all necessary host-level tasks necessary for
installing a local Unhangout installation via Vagrant.

Usage: $SCRIPT_NAME
"
}

if [ "$1" = "help" ]; then
  usage
  exit 1
fi

if [ $# -ne 0 ]; then
  usage
  exit 1
fi

find_full_path_to_file() {
  local CWD=`pwd`
  local DIR=`dirname $0`
  local FULL_PATH=`echo "$(cd "$DIR"; pwd)"`
  cd $CWD
  echo "$FULL_PATH"
}

VAGRANT_CONFIG_DIR=`find_full_path_to_file`

if [ -f ${VAGRANT_CONFIG_DIR}/settings.sh ]; then
  . ${VAGRANT_CONFIG_DIR}/settings.sh
fi
PORTS_TO_CHECK="${SSH_PORT} 7778 8080"

CWD=`pwd`

add_message() {
  local new_message=$1
  MESSAGE_STORE="$MESSAGE_STORE
 * $new_message"
}

check_executable() {
  local executable=$1
  local software=$2
  which $executable &>/dev/null
  if [ $? -ne 0 ]; then
    add_message "Test for $software failed, please install it to proceed"
  fi
}

setup_git_repo() {
  if [ ! -d "${UNHANGOUT_GIT_DIR}" ]; then
    echo "Setting up $UNHANGOUT_GIT_URL repository in ${UNHANGOUT_GIT_DIR}..."
    git clone $UNHANGOUT_GIT_URL $UNHANGOUT_GIT_DIR
    cd ${UNHANGOUT_GIT_DIR}
    if [ "$UNHANGOUT_GIT_BRANCH" = "master" ]; then
      git branch --set-upstream-to=origin/master master
      git config remote.origin.push HEAD
    else
      local git_branch=`git rev-parse --abbrev-ref HEAD`
      if [ "$git_branch" != "$UNHANGOUT_GIT_BRANCH" ]; then
        echo "Checking out ${UNHANGOUT_GIT_BRANCH}, and setting up remote tracking..."
        git checkout -t origin/${UNHANGOUT_GIT_BRANCH}
      fi
    fi
  fi
}
if [ -n "$DEV_SERVER" ]; then
  echo -n "Enter the username you were given for the main development
  server (${DEV_SERVER}): "
  read DEV_USERNAME
fi

echo "Running pre-flight checks..."
echo "Testing for internet connectivity..."
ping -c1 -q google.com &> /dev/null
if [ $? -ne 0 ]; then
  add_message "Test for internet connectivity failed, you must have an active internet connection"
fi

if [ -n "$DEV_USER" ]; then
  echo "Checking for SSH access for ${DEV_USERNAME}@${DEV_SERVER}"
  ssh ${DEV_SERVER} ls /home/${DEV_USERNAME} &> /dev/null
  if [ $? -ne 0 ]; then
    add_message "Test for SSH access for ${DEV_USERNAME}@${DEV_SERVER} failed. Make
  sure you have a user account there, and the proper config in your
  ${HOME}/.ssh/config file."
  fi

  echo "Checking for valid Salt config..."
  ssh ${DEV_SERVER} ls /home/${DEV_USERNAME}/salt/minion &> /dev/null
  if [ $? -ne 0 ]; then
    add_message "Test for valid salt config for user ${DEV_USERNAME} failed. Ask the
  system admin to set up your Salt access."
  fi
fi

for port in $PORTS_TO_CHECK; do
  echo "Checking port $port for availability..."
  open=`lsof -i -P | grep LISTEN | awk '{print $9}' | grep $port`
  if [ -n "$open" ]; then
    add_message "Port $port is currently running another process, please disable it"
  fi
done

echo "Checking for Git..."
check_executable git Git

echo "Checking for rsync..."
check_executable rsync rsync

echo "Checking for Vagrant..."
check_executable vagrant Vagrant

echo "Checking for Virtualbox..."
check_executable VBoxManage Virtualbox

if [ -n "$MESSAGE_STORE" ]; then
  echo
  echo "ERROR: pre-flight checks failed, correct the issues and run again"
  echo "$MESSAGE_STORE"
  exit 1
fi

echo "All pre-flight checks passed"

setup_git_repo

echo "Initializing development server install..."
${VAGRANT_CONFIG_DIR}/vm-init.sh "$VAGRANT_CONFIG_DIR" "$VM_INSTALL_DIR" "$UNHANGOUT_GIT_DIR" "$DEV_USERNAME" "$DEV_SERVER"

if [ -z "$MESSAGE_STORE" ]; then
  echo
  echo "Deployment successful."
  RET=0
else
  echo
  echo "ERROR: Some deployment tasks failed, check the output below for items
that may not be operating properly."
  echo "$MESSAGE_STORE"
  RET=1
fi

echo
echo "Add the following entry to your .ssh/config file, then use
'ssh ${SSH_CONFIG_LABEL}' to access the installed VM:

Host ${SSH_CONFIG_LABEL}
  Hostname localhost
  Port ${SSH_PORT}
  User root
  HostKeyAlias ${SSH_CONFIG_LABEL}
"

cd $CWD

exit $RET

